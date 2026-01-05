# -----------------------------------------------------------------------------
# g command registry (authoritative)
#
# This file is the single source of truth for:
# - available top-level g commands
# - how they are dispatched
#
# Consumers:
# - g() dispatcher
# - completion (_g)
# - g doctor

# NOTE:
# Only commands listed in G_COMMAND_DISPATCH are considered
# part of the public g command contract.
#
# Helper and maintenance commands (e.g. g_doctor) are intentionally
# NOT part of this contract.
# -----------------------------------------------------------------------------

# Associative array: command -> function
typeset -gA G_COMMAND_DISPATCH=(
  # High-level workflows
  sync     g_sync
  cleanup  g_cleanup
  fixup    g_fixup
  wip      g_wip
  sq       g_sq
  review   g_review
  bfr      bugfix-fra-feature
  tag      g_tag
  doctor   g_doctor

  # Shorthand git helpers (was case-based)
  st   g_st
  co   g_co
  cb   g_cb
  cpr  g_cpr
  br   g_br
  bc   g_bc
  b    g_b
  bd   g_bd
  bD   g_bD
  aa   g_aa
  lg   g_lg
  lo   g_lo
  df   g_df
  dc   g_dc
  p    g_p
  pf   g_pf
  pr   g_pr
  pl   g_pl
  plr  g_plr
  f    g_f
  rb   g_rb
  rbd  g_rbd
  rbi  g_rbi
  rbc  g_rbc
  rba  g_rba
  rbr  g_rbr
  rh   g_rh
  ci   g_ci
  ca   g_ca
  cae  g_cae
  c    g_c
)

# Ordered list of commands (derived, but explicit for readability)
typeset -ga G_COMMANDS=(
  # High-level workflows
  sync
  cleanup
  fixup
  wip
  sq
  review
  bfr
  tag
  doctor

  # Shorthand git helpers
  st
  co
  cb
  cpr
  br
  bc
  b
  bd
  bD
  aa
  lg
  lo
  df
  dc
  p
  pf
  pr
  pl
  plr
  f
  rb
  rbd
  rbi
  rbc
  rba
  rbr
  rh
  ci
  ca
  cae
  c
)

# Short descriptions (used by g help)
typeset -gA G_COMMAND_HELP=(
  sync    "Fetch + rebase onto default (or pull if on default)."
  cleanup "Prune merged/gone branches relative to default (prompts)."
  fixup   "Create fixup commit against default and autosquash (honors --no-rebase)."
  wip     "Create WIP commit (use --squash to amend last commit)."
  sq      "Squash last N commits (default 2); supports --interactive."
  review  "Show log/stat/diff vs default (modes: all|log|stat|diff)."
  bfr     "Create bugfix branch from release/<project>-<version>, optional cherry-pick."
  tag     "Create and push annotated tag v<version> with message."
  doctor  "Validate g registry and implementations."

  st   "git status -sb"
  co   "git checkout <branch>"
  cb   "git checkout -b <branch>"
  cpr  "git checkout - (previous branch)"
  br   "git branch"
  bc   "git branch --show-current"
  b    "git branch"
  bd   "git branch -d <branch>"
  bD   "git branch -D <branch>"
  aa   "git add --all"
  lg   "git log --oneline --graph --decorate"
  lo   "git log --oneline"
  df   "git diff"
  dc   "git diff --cached"
  p    "git push"
  pf   "git push --force-with-lease"
  pr   "git push origin HEAD --force"
  pl   "git pull"
  plr  "git pull --rebase"
  f    "git fetch"
  rb   "git rebase"
  rbd  "git rebase develop"
  rbi  "git rebase -i"
  rbc  "git rebase --continue"
  rba  "git rebase --abort"
  rbr  "git rebase -i --root"
  rh   "git reset --hard <ref>"
  ci   "git commit"
  ca   "git commit --amend"
  cae  "git commit --amend --no-edit"
  c    "git commit -m \"...\" (or open editor if no msg)"
)
