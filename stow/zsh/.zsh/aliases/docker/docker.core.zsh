# ============================================================
# Core Docker aliases and container operations
# ============================================================

# STATUS
alias d='docker'
__dreg d "Status" "d" "docker (shortcut)"

alias di='docker info'
__dreg di "Status" "di" "docker info"

alias dv='docker version'
__dreg dv "Status" "dv" "docker version"

alias dctx='docker context ls'
__dreg dctx "Status" "dctx" "List Docker contexts"

# CONTAINERS
alias dps='docker ps'
__dreg dps "Containers" "dps" "List running containers"

alias dpsa='docker ps -a'
__dreg dpsa "Containers" "dpsa" "List all containers"

alias dnames='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
__dreg dnames "Containers" "dnames" "Names / image / status / ports"

alias dstats='docker stats'
__dreg dstats "Containers" "dstats" "Live resource stats"

alias dstartc='docker start'
__dreg dstartc "Containers" "dstartc <c>" "Start container"

alias dstopc='docker stop'
__dreg dstopc "Containers" "dstopc <c>" "Stop container"

alias drestart='docker restart'
__dreg drestart "Containers" "drestart <c>" "Restart container"

alias dtop='docker top'
__dreg dtop "Containers" "dtop <c>" "Container processes"

alias dinspect='docker inspect'
__dreg dinspect "Containers" "dinspect <obj>" "Inspect container/image/network/volume"

alias dcp='docker cp'
__dreg dcp "Containers" "dcp <src> <dst>" "Copy files to/from container"

dshell() {
  docker exec -it "$1" /bin/sh 2>/dev/null || docker exec -it "$1" /bin/bash
}
__dreg dshell "Containers" "dshell <c>" "Shell into container (sh → bash)"

dkillport() {
  docker ps --format "{{.ID}} {{.Ports}}" | grep -E "(^|:)$1->|:$1-" | awk '{print $1}' | xargs -r docker stop
}
__dreg dkillport "Containers" "dkillport <port>" "Stop containers using a port"

# IMAGES
alias dimages='docker images'
__dreg dimages "Images" "dimages" "List images"

alias dpull='docker pull'
__dreg dpull "Images" "dpull <image>" "Pull image"

alias drmi='docker rmi'
__dreg drmi "Images" "drmi <image>" "Remove image"

alias dimageprune='docker image prune'
__dreg dimageprune "Images" "dimageprune" "Remove unused images"

dimagepruneall() {
  __dconfirm "Remove ALL unused images (docker image prune -a)?" || return 1
  docker image prune -a
}
__dreg dimagepruneall "Images" "dimagepruneall" "Remove all unused images (dangerous)"
