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
  sync     g_sync
  cleanup  g_cleanup
  fixup    g_fixup
  wip      g_wip
  sq       g_sq
  review   g_review
  bfr      bugfix-fra-feature
  tag      g_tag
)

# Ordered list of commands (derived, but explicit for readability)
typeset -ga G_COMMANDS=(
  sync
  cleanup
  fixup
  wip
  sq
  review
  bfr
  tag
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
)
