# ============================================================
# Docker Compose
# ============================================================

alias dc='docker compose'
__dreg dc "Compose" "dc [cmd]" "docker compose"

alias dcup='docker compose up'
__dreg dcup "Compose" "dcup" "compose up"

alias dcupd='docker compose up -d'
__dreg dcupd "Compose" "dcupd" "compose up -d"

alias dcdown='docker compose down'
__dreg dcdown "Compose" "dcdown" "compose down"

alias dclogs='docker compose logs -f'
__dreg dclogs "Compose" "dclogs" "compose logs -f"

alias dcps='docker compose ps'
__dreg dcps "Compose" "dcps" "compose ps"

alias dcrestart='docker compose restart'
__dreg dcrestart "Compose" "dcrestart" "compose restart"
