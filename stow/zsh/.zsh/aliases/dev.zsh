# -----------------------------------------------------------------------------
# Development tool aliases
# -----------------------------------------------------------------------------

# npm
alias rdev='npm run dev'
alias nst='npm start'
alias prt='npm run prettier'
alias nrt='npm run test'

# maven
alias mvnci='mvn clean install'
alias mvnist='mvn clean install -DskipTests'
alias mvncp='mvn clean package'
alias mvncc='mvn clean compile'
alias mvnt='mvn test'
alias mvnct='mvn clean test'
alias mvnc='mvn clean'
alias mvnd='mvn deploy'
alias mvns='mvn spring-boot:run'
alias mvnu='mvn clean install -U'
alias mvnver='mvn --version'
alias mvnfmt='mvn spotless:apply'
alias mvnsite='mvn site'
alias mvnverify='mvn verify'
alias mvnsh='mvn dependency:tree'
alias tmuxstatus='[ -n "$TMUX" ] && echo "i tmux" || echo "ikke i tmux"'
alias restkall="$HOME/dotfiles/scripts/rest-kall.sh"

# misc dev
alias loc="npx sloc --format cli-table --format-option head --exclude 'build|\\.svg$\\.xml' ./"
