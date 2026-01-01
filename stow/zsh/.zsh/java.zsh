# -----------------------------------------------------------------------------
# Java runtime policy (silent, PATH-safe)
# -----------------------------------------------------------------------------

# Internal: remove previous Java paths from PATH (zsh builtins only)
_java_clean_path() {
  local new_path=()
  local dir

  for dir in ${(s/:/)PATH}; do
    [[ "$dir" == */JavaVirtualMachines/*/bin ]] && continue
    new_path+=("$dir")
  done

  PATH="${(j/:/)new_path}"
}

# Default Java (Temurin 21)
if [[ -x /usr/libexec/java_home ]]; then
  JAVA_HOME="$(/usr/libexec/java_home -v 21 2>/dev/null)"
  if [[ -n "$JAVA_HOME" && -x "$JAVA_HOME/bin/java" ]]; then
    _java_clean_path
    export JAVA_HOME
    PATH="$JAVA_HOME/bin:$PATH"
  fi
fi

# Switch Java version
j() {
  [[ -n "$1" ]] || { echo "Usage: j <version>"; return 1; }

  local home
  home="$(/usr/libexec/java_home -v "$1" 2>/dev/null)" || {
    echo "❌ Java $1 not found"
    return 1
  }

  _java_clean_path
  export JAVA_HOME="$home"
  PATH="$JAVA_HOME/bin:$PATH"

  echo "☕ Java $(java -version 2>&1 | head -n1)"
}

# List installed Java versions
jls() {
  /usr/libexec/java_home -V 2>&1 | sed '1d'
}

# Delete Java version
jd() {
  [[ -n "$1" ]] || {
    echo "Usage: jd <version>"
    echo
    echo "Installed Java versions:"
    jls
    return 1
  }

  local version="$1"
  local found=0
  local v

  for v in $(jls); do
    [[ "$v" == "$version" ]] && found=1
  done

  if [[ "$found" -ne 1 ]]; then
    echo "❌ Java $version is not installed."
    echo
    echo "Installed Java versions:"
    jls
    return 1
  fi

  local jdk="/Library/Java/JavaVirtualMachines/temurin-$version.jdk"

  if [[ ! -d "$jdk" ]]; then
    echo "❌ Expected Temurin JDK not found:"
    echo "   $jdk"
    return 1
  fi

  echo "⚠️  This will uninstall Java $version (Temurin)"
  read -r "?Proceed? [y/N] " confirm

  [[ "$confirm" == "y" || "$confirm" == "Y" ]] || {
    echo "Aborted."
    return 1
  }

  sudo rm -rf "$jdk"

  echo "✅ Java $version uninstalled."
}

