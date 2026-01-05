#!/usr/bin/env bash
set -euo pipefail

# PKCE + sessionToken flow (Okta), optional GET call after login.
# Usage:
#   scripts/rest-login-pkce.sh                 # bare login, print token
#   scripts/rest-login-pkce.sh https://api/... # login, then GET endpoint med Bearer-token

OKTA_ISSUER="${OKTA_ISSUER:-https://app.test.nanomobil.no/oauth2/aus9fqa4ku86wYxE30x7}"
CLIENT_ID="${CLIENT_ID:-0oa1lz7nfi1KCAQlH0x7}"
USERNAME="${USERNAME:-ngflyt}"
PASSWORD="${PASSWORD:-Asko1234}"
SCOPE="${SCOPE:-openid groups profile}"
REDIRECT_URI="${REDIRECT_URI:-https://admin.test.ngflyt.no/login/callback}"

die() {
  echo "❌ $*" >&2
  exit 1
}

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Mangler kommando: $1"; }
require_cmd jq
require_cmd openssl

if [[ -z "$OKTA_ISSUER" || -z "$CLIENT_ID" || -z "$USERNAME" || -z "$PASSWORD" ]]; then
  die "OKTA_ISSUER, CLIENT_ID, USERNAME, PASSWORD må settes."
fi

# Derive domain/auth server from issuer
tmp="${OKTA_ISSUER#https://}"
tmp="${tmp#http://}"
AUTH_SERVER="${tmp##*/}"
DOMAIN="${tmp%%/oauth2/*}"
OKTA_DOMAIN="https://${DOMAIN}"

echo "---- Config ----"
echo "ISSUER        : $OKTA_ISSUER"
echo "DOMAIN        : $OKTA_DOMAIN"
echo "AUTH_SERVER   : $AUTH_SERVER"
echo "CLIENT_ID     : $CLIENT_ID"
echo "USERNAME      : $USERNAME"
echo "SCOPE         : $SCOPE"
echo "REDIRECT_URI  : $REDIRECT_URI"
echo "----------------"

# Generate PKCE verifier/challenge using openssl rand + sha256
code_verifier=$(openssl rand -base64 48 | tr '+/' '-_' | tr -d '=') || die "Kunne ikke generere code_verifier"
code_challenge=$(printf '%s' "$code_verifier" | openssl sha256 -binary | openssl base64 | tr '+/' '-_' | tr -d '=') || die "Kunne ikke generere code_challenge"
echo "code_verifier : $code_verifier"
echo "code_challenge: $code_challenge"

state=$(openssl rand -hex 16) || die "Kunne ikke generere state"
nonce=$(openssl rand -hex 16) || die "Kunne ikke generere nonce"

echo "➡️  Authn for sessionToken..."
authn_resp=$(curl -s -X POST "$OKTA_DOMAIN/api/v1/authn" \
  -H "Content-Type: application/json" \
  -d '{"username":"'"$USERNAME"'","password":"'"$PASSWORD"'","options":{"warnBeforePasswordExpired":true,"multiOptionalFactorEnroll":false}}')

session_token=$(echo "$authn_resp" | jq -r '.sessionToken // empty')
status=$(echo "$authn_resp" | jq -r '.status // empty')
if [[ -z "$session_token" || "$status" != "SUCCESS" ]]; then
  die "Klarte ikke hente sessionToken. Respons: $(echo "$authn_resp" | jq -c '.? // .')"
fi
echo "✅ sessionToken mottatt"

echo "➡️  Henter auth code (authorize)..."
auth_headers=$(mktemp)
auth_body=$(mktemp)
auth_status=$(curl -s -o "$auth_body" -D "$auth_headers" -w "%{http_code}" -G "$OKTA_DOMAIN/oauth2/$AUTH_SERVER/v1/authorize" \
  --data-urlencode "client_id=$CLIENT_ID" \
  --data-urlencode "response_type=code" \
  --data-urlencode "response_mode=query" \
  --data-urlencode "redirect_uri=$REDIRECT_URI" \
  --data-urlencode "scope=$SCOPE" \
  --data-urlencode "state=$state" \
  --data-urlencode "nonce=$nonce" \
  --data-urlencode "code_challenge=$code_challenge" \
  --data-urlencode "code_challenge_method=S256" \
  --data-urlencode "sessionToken=$session_token")

code=""
if [[ "$auth_status" == "302" ]]; then
  loc=$(grep -i '^Location:' "$auth_headers" | tail -n1 | awk '{$1=""; sub(/^ /,""); print}')
  code=$(printf '%s' "$loc" | sed 's/.*code=\([^&]*\).*/\1/')
fi

if [[ -z "$code" ]]; then
  echo "❌ Fant ikke code. Status $auth_status. Headers/Body følger:"
  cat "$auth_headers"
  echo "---"
  cat "$auth_body"
  rm -f "$auth_headers" "$auth_body"
  exit 1
fi
rm -f "$auth_headers" "$auth_body"
echo "✅ Auth code mottatt"

echo "➡️  Bytter code mot access token..."
token_resp=$(curl -s -X POST "$OKTA_DOMAIN/oauth2/$AUTH_SERVER/v1/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "client_id=$CLIENT_ID" \
  -d "redirect_uri=$REDIRECT_URI" \
  -d "code=$code" \
  -d "code_verifier=$code_verifier")

access_token=$(echo "$token_resp" | jq -r '.access_token // empty')
id_token=$(echo "$token_resp" | jq -r '.id_token // empty')

if [[ -z "$access_token" ]]; then
  die "Klarte ikke hente access_token. Respons: $(echo "$token_resp" | jq -c '.? // .')"
fi

echo "✅ access_token mottatt"
echo
echo "---- Tokens ----"
echo "access_token (kort): ${access_token:0:20}...${access_token: -8}"
if [[ -n "$id_token" ]]; then
  echo "id_token    (kort): ${id_token:0:20}...${id_token: -8}"
fi
echo "----------------"
echo "Eksporter for videre bruk:"
echo "export ACCESS_TOKEN=\"$access_token\""

# Optional: call an endpoint if URL is provided
API_URL="${1:-}"
if [[ -n "$API_URL" ]]; then
  echo
  echo "➡️  GET $API_URL med Bearer-token"
  curl -i -X GET "$API_URL" \
    -H "Authorization: Bearer $access_token" \
    -H "Accept: application/json"
fi
