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

alias loc="npx sloc --format cli-table --format-option head --exclude 'build|\\.svg$\\.xml' ./"

jm() {
  j "$1" && mvnist
}

mvn-auto-java() {
  local root="${1:-.}"
  local java_version=""

  echo "🔍 Finner Java-versjon brukt av Maven-prosjektet …"

  local pom
  pom=$(find "$root" -name pom.xml | head -n 1)

  if [[ -z "$pom" ]]; then
    echo "❌ Fant ingen pom.xml"
    return 1
  fi

  java_version=$(mvn -q -f "$pom" help:evaluate \
    -Dexpression=maven.compiler.release \
    -DforceStdout 2>/dev/null)

  if [[ -z "$java_version" || "$java_version" == "null" ]]; then
    java_version=$(mvn -q -f "$pom" help:evaluate \
      -Dexpression=maven.compiler.source \
      -DforceStdout 2>/dev/null)
  fi

  # 3️⃣ Fallback til target
  if [[ -z "$java_version" || "$java_version" == "null" ]]; then
    java_version=$(mvn -q -f "$pom" help:evaluate \
      -Dexpression=maven.compiler.target \
      -DforceStdout 2>/dev/null)
  fi

  if [[ -z "$java_version" || "$java_version" == "null" ]]; then
    echo "❌ Klarte ikke å bestemme Java-versjon fra Maven"
    return 1
  fi

  echo "☕ Prosjektet bruker Java $java_version"

  echo "🔁 Setter Java $java_version"
  j "$java_version" || {
    echo "❌ Kunne ikke sette Java $java_version"
    return 1
  }

  echo "🏗️  Kjører mvnist"
  mvnist
}