#!/usr/bin/env bash
# Bruk: git bfr [--check] [--cherry-pick <count>] [--include-merges] [YY.MM]
# Lager bugfix-branch fra feature-branch og cherry-picker commits ved behov

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/branch-script-helpers.zsh"

bugfix-fra-feature() {
    local version="" mode="normal" commit_count="" include_merges=false

    farge_init

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check|-c) mode="check"; shift ;;
            --cherry-pick|-p) commit_count="$2"; shift 2 ;;
            --include-merges|-m) include_merges=true; shift ;;
            *) version="$1"; shift ;;
        esac
    done

    kontroller_git_dir || { echo -e "${RED}❌ Du er ikke i et git repo.${RESET}"; return 1; }

    local project
    project=$(finn_prosjekt) || { echo -e "${RED}❌ Kunne ikke finne git URL.${RESET}"; return 1; }
    echo -e "${CYAN}🧠 Fant prosjekt:${RESET} ${BOLD}${project}${RESET}"

    # Detect version
    if [[ -z "$version" ]]; then
        version=$(finn_versjon "$project")
        [[ -z "$version" ]] && { echo -e "${RED}❌ Ingen release funnet for ${project}.${RESET}"; return 1; }
        echo -e "${GREEN}🧠 Automatisk valgt versjon:${RESET} ${BOLD}${version}${RESET}"
    fi

    local curr_branch
    curr_branch=$(git rev-parse --abbrev-ref HEAD)
    [[ "$curr_branch" == "HEAD" ]] && {
        echo -e "${YELLOW}⚠️  Detached HEAD funnet.${RESET}"
        curr_branch=$(git reflog | grep checkout | tail -1 | awk '{print $NF}')
    }

    [[ ! "$curr_branch" =~ ^feature/ ]] && { echo -e "${RED}❌ Branch må være en feature-branch.${RESET}"; return 1; }

    local feature_name="${curr_branch#feature/}"
    local release_branch="release/${project}-${version}"
    local bugfix_branch="bugfix/${feature_name}"

    # Dry run
    if [[ "$mode" == "check" ]]; then
        echo ""
        echo -e "${CYAN}🧩  Dry-run (Ingen endringer vil bli gjort)${RESET}"
        echo "------------------------------------------"
        echo -e "Prosjekt:       ${BOLD}${project}${RESET}"
        echo -e "Feature branch: ${BOLD}${curr_branch}${RESET}"
        echo -e "Release branch: ${BOLD}${release_branch}${RESET}"
        echo -e "Bugfix branch:  ${BOLD}${bugfix_branch}${RESET}"
        [[ -z "$commit_count" ]] && echo -e "${YELLOW}(Ingen commits vil bli inkludert)${RESET}"
        if [[ -n "$commit_count" ]]; then
            echo -e "Cherry-pick:    ${BOLD}${commit_count}${RESET} commits"
            [[ "$include_merges" == true ]] && echo -e "${YELLOW}(Merge commits vil bli inkludert)${RESET}" || echo -e "${YELLOW}(Merge commits vil bli hoppet over)${RESET}"
            echo ""
            echo "Følgende commits ville blitt cherry-picket:"
            git --no-pager log -n "$commit_count" --oneline "$curr_branch" $([[ "$include_merges" == false ]] && echo "--no-merges")
        fi
        echo "------------------------------------------"
        echo -e "${GREEN}✅ Dry-run ferdig. Bruk uten --check for å gjøre endringer.${RESET}"
        return 0
    fi

    bytt_til_release_branch "$release_branch" || return 1
    opprett_bugfix_branch "$bugfix_branch"

    [[ -n "$commit_count" ]] && exec_cherry_pick "$curr_branch" "$commit_count" "$include_merges"

    if [[ -z "$commit_count" ]]; then
        echo ""
        echo -e "${YELLOW}ℹ️  Cherry-pick not performed.${RESET}"
        echo -e "   Use ${BOLD}--cherry-pick <count>${RESET} to include recent commits from your feature branch."
    fi

    echo -e "${GREEN}✅ Ferdig! Nå på branch:${RESET} ${BOLD}${bugfix_branch}${RESET}"
}