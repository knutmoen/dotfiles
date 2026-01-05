#!/usr/bin/env bash
set -euo pipefail

# PKCE + sessionToken flow (Okta) with simple access_token caching.
# Reuses a cached access_token until it expires, then performs authn+PKCE again.
# Usage:
#   scripts/rest-login-pkce-cache.sh                  # fetch token (uses cache) and print summary
#   scripts/rest-login-pkce-cache.sh https://api/...  # fetch token (uses cache) and GET endpoint
#
# Optional local config (not tracked): ~/.rest-pkce.env or ~/.config/rest-pkce.env
for cfg in "$HOME/.rest-pkce.env" "$HOME/.config/rest-pkce.env"; do
  [[ -f "$cfg" ]] && source "$cfg"
done

# Env you can override (set via env file, see rest-pkce.env.example):
#   OKTA_ISSUER, CLIENT_ID, USERNAME, PASSWORD, SCOPE, REDIRECT_URI, CACHE_FILE, SKEW_SECONDS

OKTA_ISSUER="${OKTA_ISSUER:-}"
CLIENT_ID="${CLIENT_ID:-}"
USERNAME="${USERNAME:-}"
PASSWORD="${PASSWORD:-}"
SCOPE="${SCOPE:-}"
REDIRECT_URI="${REDIRECT_URI:-}"
CACHE_FILE="${CACHE_FILE:-$HOME/.cache/rest-pkce-token.json}"
SKEW_SECONDS="${SKEW_SECONDS:-60}"

die() { echo "❌ $*" >&2; exit 1; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Mangler kommando: $1"; }

require_cmd jq
require_cmd openssl
require_cmd curl

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
echo "CACHE_FILE    : $CACHE_FILE"
echo "----------------"

get_cached_token() {
  [[ -f "$CACHE_FILE" ]] || return 1
  local now exp tok
  now=$(date +%s)
  exp=$(jq -r '.expires_at // empty' "$CACHE_FILE") || return 1
  tok=$(jq -r '.access_token // empty' "$CACHE_FILE") || return 1
  if [[ -z "$tok" || -z "$exp" ]]; then
    return 1
  fi
  if (( now + SKEW_SECONDS >= exp )); then
    return 1
  fi
  ACCESS_TOKEN="$tok"
  ACCESS_EXPIRES_AT="$exp"
  return 0
}

login_and_get_token() {
  # PKCE
  code_verifier=$(openssl rand -base64 48 | tr '+/' '-_' | tr -d '=') || die "Kunne ikke generere code_verifier"
  code_challenge=$(printf '%s' "$code_verifier" | openssl sha256 -binary | openssl base64 | tr '+/' '-_' | tr -d '=') || die "Kunne ikke generere code_challenge"
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

  ACCESS_TOKEN=$(echo "$token_resp" | jq -r '.access_token // empty')
  expires_in=$(echo "$token_resp" | jq -r '.expires_in // empty')
  if [[ -z "$ACCESS_TOKEN" ]]; then
    die "Klarte ikke hente access_token. Respons: $(echo "$token_resp" | jq -c '.? // .')"
  fi
  if [[ -n "$expires_in" && "$expires_in" =~ ^[0-9]+$ ]]; then
    ACCESS_EXPIRES_AT=$(( $(date +%s) + expires_in ))
  else
    ACCESS_EXPIRES_AT=$(( $(date +%s) + 300 ))
  fi

  mkdir -p "$(dirname "$CACHE_FILE")"
  jq -n --arg token "$ACCESS_TOKEN" --argjson exp "$ACCESS_EXPIRES_AT" '{access_token:$token, expires_at:$exp}' >"$CACHE_FILE"

  echo "✅ access_token mottatt og cachet til $CACHE_FILE"
  echo "expires_at (epoch): $ACCESS_EXPIRES_AT"
}

# Main: get token (cached or fresh)
ACCESS_TOKEN=""
ACCESS_EXPIRES_AT=""
if get_cached_token; then
  echo "ℹ️  Bruker cachet token (utløper: $ACCESS_EXPIRES_AT)"
else
  login_and_get_token
fi

echo
echo "---- Tokens ----"
echo "access_token (kort): ${ACCESS_TOKEN:0:20}...${ACCESS_TOKEN: -8}"
echo "expires_at (epoch) : ${ACCESS_EXPIRES_AT:-<ukjent>}"
echo "----------------"
echo "Eksporter for videre bruk:"
echo "export ACCESS_TOKEN=\"$ACCESS_TOKEN\""

# Optional: call an endpoint if URL is provided
API_URL="${1:-}"
if [[ -n "$API_URL" ]]; then
  echo
  echo "➡️  GET $API_URL med Bearer-token"
  curl -i -X GET "$API_URL" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Accept: application/json"
fi
