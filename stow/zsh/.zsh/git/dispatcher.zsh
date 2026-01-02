# We use g as a function, not OMZ alias
unalias g 2>/dev/null

g() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  local cmd="$1"
  shift || true

  case "$cmd" in
    ""|st) git status -sb ;;

    # Branching
    co)  git checkout "$@" ;;
    cb)  git checkout -b "$@" ;;
    cpr) git checkout - ;;
    br)  git branch ;;
    bc)  git branch --show-current ;;

    # Branch mgmt
    b)   git branch ;;
    bd)  git branch -d "$1" ;;
    bD)  git branch -D "$1" ;;

    # Staging
    aa) git add --all ;;

    # Logs
    lg) git log --oneline --graph --decorate ;;
    lo) git log --oneline ;;

    # Diff
    df) git diff ;;
    dc) git diff --cached ;;

    # Push/pull
    p)  git push ;;
    pf) git push --force-with-lease ;;
    pr) git push origin HEAD --force ;;
    pl) git pull ;;
    plr) git pull --rebase ;;
    f)  git fetch ;;

    # Rebase/reset
    rb) git rebase ;;
    rbd) git rebase develop ;;
    rbi) git rebase -i ;;
    rbc) git rebase --continue ;;
    rba) git rebase --abort ;; 
    rbr) git rebase -i --root ;;
    rh) git reset --hard "${2:-HEAD}" ;;

    bfr) bugfix-fra-feature "$@" ;;

    # Commit
    ci) git commit "$@" ;;
    ca) git commit --amend ;;
    cae) git commit --amend --no-edit ;;
    c)
      if [[ $# -eq 0 ]]; then
        git commit
      else
        git commit -m "$*"
      fi
    ;;

    sync)    g_sync ;;
    cleanup) g_cleanup ;;
    fixup)   g_fixup "$@" ;;
    wip)     g_wip "$@" ;;
    sq)      g_sq "$@" ;;
    review)  g_review "$@" ;;
    doctor)  g_doctor ;;

    *) git "$cmd" "$@" ;;
  esac
}
