# -----------------------------------------------------------------------------
# Simple git shorthands for g dispatcher
# -----------------------------------------------------------------------------

g_st()   { git status -sb "$@"; }
g_co()   { git checkout "$@"; }
g_cb()   { git checkout -b "$@"; }
g_cpr()  { git checkout -; }
g_cp()   { git cherry-pick "$@"; }
g_br()   { git branch "$@"; }
g_bc()   { git branch --show-current; }
g_b()    { git branch "$@"; }
g_bd()   { git branch -d "$@"; }
g_bD()   { git branch -D "$@"; }
g_aa()   { git add --all "$@"; }
g_lg()   { git log --oneline --graph --decorate "$@"; }
g_lo()   { git log --oneline "$@"; }
g_df()   { git diff "$@"; }
g_dc()   { git diff --cached "$@"; }
g_p()    { git push "$@"; }
g_pf()   { git push --force-with-lease "$@"; }
g_pr()   { git push origin HEAD --force "$@"; }
g_pl()   { git pull "$@"; }
g_plr()  { git pull --rebase "$@"; }
g_f()    { git fetch "$@"; }
g_rb()   { git rebase "$@"; }
g_rbd()  { git rebase develop "$@"; }
g_rbi()  { git rebase -i "$@"; }
g_rbc()  { git rebase --continue "$@"; }
g_rba()  { git rebase --abort "$@"; }
g_rbr()  { git rebase -i --root "$@"; }
g_rh()   { git reset --hard "${1:-HEAD}"; }
g_ci()   { git commit "$@"; }
g_ca()   { git commit --amend "$@"; }
g_cae()  { git commit --amend --no-edit "$@"; }
g_c()    {
  if [[ $# -eq 0 ]]; then
    git commit
  else
    git commit -m "$*"
  fi
}
