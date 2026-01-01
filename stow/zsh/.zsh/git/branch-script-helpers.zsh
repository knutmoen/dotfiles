#!/usr/bin/env bash
# Hjelpefunksjoner for bugfix-fra-feature

farge_init() {
    if [[ -t 1 && "$TERM" != "dumb" ]]; then
        RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"
        CYAN="\033[0;36m"; BOLD="\033[1m"; RESET="\033[0m"
    else
        RED=""; GREEN=""; YELLOW=""; CYAN=""; BOLD=""; RESET=""
    fi
}

finn_prosjekt() {
    local remote_url
    remote_url=$(git config --get remote.origin.url 2>/dev/null) || return 1
    [[ -z "$remote_url" ]] && return 1
    basename "$remote_url" .git
}

kontroller_git_dir() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
}

finn_versjon() {
    local project="$1" releases version
    echo -e "${CYAN}🔍 Søker etter siste release versjon for${RESET} ${BOLD}${project}${RESET}..." >&2
    if git ls-remote --exit-code --heads origin >/dev/null 2>&1; then
        releases=$(git ls-remote --heads origin "refs/heads/release/${project}-*" 2>/dev/null |
            sed -E "s#.*/release/${project}-([0-9]{2}\.[0-9]{1,2}).*#\1#" |
            sort -t. -k1,1nr -k2,2nr)
    else
        echo -e "${YELLOW}⚠️  Fikk ikke kontakt med origin. Prøver lokale brancher...${RESET}" >&2
        releases=$(git branch --list "release/${project}-*" 2>/dev/null |
            sed -E "s#.*release/${project}-([0-9]{2}\.[0-9]{1,2}).*#\1#" |
            sort -t. -k1,1nr -k2,2nr)
    fi
    version=$(echo "$releases" | head -n 1)
    echo "$version"
}

bytt_til_release_branch() {
    local release_branch="$1"
    if git show-ref --verify --quiet "refs/heads/${release_branch}"; then
        echo -e "${CYAN}📦 Fant lokal release branch. Sjekker ut...${RESET}"
        git checkout "$release_branch" && git pull origin "$release_branch" || return 1
    elif git show-ref --verify --quiet "refs/remotes/origin/${release_branch}"; then
        echo -e "${YELLOW}⚠️  Release branch finnes bare i origin. Gjør fetch:${RESET}"
        git fetch origin "${release_branch}:${release_branch}" || return 1
        git checkout "$release_branch"
    else
        echo -e "${RED}❌ Release branch ikke funnet lokalt eller i origin:${RESET}\n    ${release_branch}"
        return 1
    fi
}

opprett_bugfix_branch() {
    local bugfix_branch="$1"
    echo -e "${CYAN}🌱 Oppretter ny branch:${RESET} ${BOLD}${bugfix_branch}${RESET}"
    if git show-ref --verify --quiet "refs/heads/${bugfix_branch}"; then
        echo -e "${YELLOW}⚠️  Branch ${bugfix_branch} finnes allerede. Sjekker ut...${RESET}"
        git checkout "$bugfix_branch"
    else
        git checkout -b "$bugfix_branch"
    fi
}

exec_cherry_pick() {
    local curr_branch="$1" count="$2" include_merges="$3"
    echo -e "${CYAN}🔍 Cherry-picker de siste ${count} commits fra${RESET} ${BOLD}${curr_branch}${RESET}..."
    local commits commit msg total_merges=0

    if [[ "$include_merges" == true ]]; then
        echo -e "${YELLOW}⚙️  Inkluderer merge commits under cherry-pick.${RESET}"
        commits=$(git log -n "$count" --reverse --pretty=format:"%H" "$curr_branch")
    else
        echo -e "${CYAN}ℹ️  Hopper over merge commits (default oppførsel).${RESET}"
        total_merges=$(git log -n "$count" --merges --pretty=format:"%H" "$curr_branch" | wc -l | tr -d ' ')
        commits=$(git log -n "$count" --reverse --no-merges --pretty=format:"%H" "$curr_branch")
    fi

    for commit in $commits; do
        msg=$(git log -1 --pretty=format:"%s" "$commit")
        echo -e "➡️  ${BOLD}${commit}${RESET} — ${msg}"
        if ! git cherry-pick "$commit" >/dev/null 2>&1; then
            if git diff --quiet HEAD; then
                echo -e "${YELLOW}⚠️  Tom commit (${commit}). Hopper over...${RESET}"
                git cherry-pick --skip >/dev/null 2>&1 || true
            else
                echo -e "${RED}❌ Konflikt under cherry-pick av ${commit}.${RESET}"
                echo -e "${YELLOW}   Løs konflikten og kjør:${RESET} git cherry-pick --continue"
                return 1
            fi
        fi
    done

    if [[ "$include_merges" == false && "$total_merges" -gt 0 ]]; then
        echo -e "${CYAN}ℹ️  Skippet ${BOLD}${total_merges}${RESET} merge commits.${RESET}"
    fi

    echo -e "${GREEN}✅ Cherry-pick fullført uten problemer!${RESET}"
}