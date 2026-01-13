# -----------------------------------------------------------------------------
# Dotfiles help (interactive)
# -----------------------------------------------------------------------------

[[ -o interactive ]] || return 0

dotfiles_help() {
  emulate -L zsh
  setopt LOCAL_OPTIONS NO_SH_WORD_SPLIT

  printf "Dotfiles-kommandoer (dfhelp)\n\n"

  echo "Grunnleggende:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
mkcd|mkdir og cd inn i ny mappe
c|clear
home|cd ~
zshsource|reload ~/.zshrc
zshconfig|open ~/.zshrc i $EDITOR
zshdir|cd ~/.zsh
codezsh|open ~/.zsh i editor
dotfiles|cd ~/dotfiles
confdotfiles|open ~/dotfiles i editor
port|list prosesser som lytter paa port
killport|kill prosesser som lytter paa port
EOF
  echo

  echo "Navigasjon:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
cproj|velg katalog i $WORK_PROJECTS_DIR (fzf)
cpriv|velg katalog i $PERSONAL_PROJECTS_DIR (fzf)
cgit|velg git-repo under ~/development (fzf)
EOF
  echo

  echo "Utvikling:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
rdev|npm run dev
nst|npm start
prt|npm run prettier
nrt|npm run test
restkall|alias til scripts/rest-kall.sh
loc|sloc via npx sloc
EOF
  echo

  echo "Maven:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
mvnci|mvn clean install
mvnist|mvn clean install -DskipTests
mvncp|mvn clean package
mvncc|mvn clean compile
mvnt|mvn test
mvnct|mvn clean test
mvnc|mvn clean
mvnd|mvn deploy
mvns|mvn spring-boot:run
mvnu|mvn clean install -U
mvnver|mvn --version
mvnfmt|mvn spotless:apply
mvnsite|mvn site
mvnverify|mvn verify
mvnsh|mvn dependency:tree
EOF
  echo

  echo "Node / Volta:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
vinstall|installer node-versjon globalt (volta install node@<versjon>)
vuse|alias til vinstall
vpin|pin node-versjon i prosjekt
vls|list installert/pinnet node
EOF
  echo

  echo "Java:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
j|bytt Java-versjon (bruker /usr/libexec/java_home)
jls|list installerte Java-versjoner
jd|avinstaller Temurin-versjon
EOF
  echo

  echo "Tmux:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
t|attach eller opprett tmux-session (t default)
tboot|start frontend/backend/commands sessions (dersom direktorier satt)
tf|t frontend
tb|t backend
tc|t commands
td|t dev
tmuxstatus|vis om du er i tmux
EOF
  echo

  echo "Arbeid (krever WORK_PROFILE=1):"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
kode|cd $WORK_PROJECTS_DIR
an|cd $WORK_PROJECTS_DIR/asko-netthandel
btkapi|cd $WORK_PROJECTS_DIR/asko-netthandel/butikk-api
btkapirun|cd $WORK_PROJECTS_DIR/asko-netthandel/butikk-api-application-runner
ngfweb|cd $WORK_PROJECTS_DIR/ngf-webklient/ngf-webklient
mobil|cd $WORK_PROJECTS_DIR/ngf-mobilklient/ngf-klient
adminweb|cd $WORK_PROJECTS_DIR/ngf-admin/ngf-admin-web
elpweb|cd $WORK_PROJECTS_DIR/elp-web/elp-web
elpapi|cd $WORK_PROJECTS_DIR/elp-api
elpjobb|cd $WORK_PROJECTS_DIR/elp-jobber
felleskomponenter|cd $WORK_PROJECTS_DIR/felleskomponenter
rek|cd $WORK_PROJECTS_DIR/rek
ccs|clear_chrome_session
EOF
  echo "Personlig: PERSONAL_PROJECTS_DIR settes i aliases/personal.zsh (ingen faste alias her)."
  echo

  echo "Git (g):"
  if typeset -f g_help >/dev/null; then
    g_help
  else
    echo "  g <cmd> (git-modul ikke lastet enda; kjør g help manuelt)"
  fi
  echo

  echo "Scripts:"
  while IFS='|' read -r cmd desc; do
    [[ -z "$cmd" ]] && continue
    printf "  %-15s %s\n" "$cmd" "$desc"
  done <<'EOF'
scripts/install-git-hooks.sh|installer git hooks for repoet
scripts/rest-login-pkce.sh|hent Access Token med PKCE
scripts/rest-login-pkce-cache.sh|PKCE-login med token-cache
scripts/iterm-set-font.applescript|sett font for iTerm (AppleScript)
EOF
  echo "Tips: Kjor g help <command> for detaljerte git-beskrivelser."
}

alias dfhelp=dotfiles_help
