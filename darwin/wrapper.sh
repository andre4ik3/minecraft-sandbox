#!/bin/sh

# $INST_NAME - Name of the instance
# $INST_ID - ID of the instance (its folder name)
# $INST_DIR - absolute path of the instance
# $INST_MC_DIR - absolute path of Minecraft
# $INST_JAVA - Java binary used for launch
# $INST_JAVA_ARGS - command-line parameters used for launch (warning: will not work correctly if arguments contain spaces)

set -e

self="$(realpath "$(dirname "$0")")"
profile="$(realpath "$self/profile.sb")"

# Config helper
getenv() {
  eval "var=\${$1}"
  case $var in
    true|false)
      echo "$var"
      ;;
    '')
      echo "$2"
      ;;
    *)
      >&2 echo "Wrapper: $1 must be either 'true' or 'false', instead got '$var'"
      exit 1
      ;;
  esac
}


# Find classpath and natives directory, process arguments
classpath="0"
native_dir=""
for arg in "$@"; do
    if [ "$classpath" = "1" ]; then
      classpath="$arg"
      continue
    fi

    case "$arg" in
      -cp)
        classpath="1"
        ;;
      -Djava.library.path=*)
        native_dir="${arg#-Djava.library.path=}"
        ;;
    esac
done

# Ensure the working directory is the instance folder
cd "$INST_MC_DIR" || exit 1

# Are we running (Neo)Forge?
echo "$classpath" | grep -q "forge" && is_forge="true" || is_forge="false"

# Process config from environment variables
allow_all_libraries="$(getenv "SANDBOX_ALLOW_ALL_LIBRARIES" "$is_forge")"
allow_microphone="$(getenv "SANDBOX_ALLOW_MICROPHONE" "false")"
allow_multiplayer="$(getenv "SANDBOX_ALLOW_MULTIPLAYER" "true")"

# Other directories
minecraft="$(realpath "$INST_MC_DIR")"
assets="$(realpath "$INST_DIR/../../assets")"
libraries="$(realpath "$INST_DIR/../../libraries")"
java="$(realpath "$INST_JAVA")"
java_home="$(realpath "$(echo "$java" | sed "s;/Contents/Home/.*;;")"/..)"

echo "=============================================="
echo
echo "Executing Minecraft with macOS Sandbox Wrapper"
echo
echo " => Minecraft: $(echo "$minecraft" | sed "s;$HOME;~;")"
echo " => Assets: $(echo "$assets" | sed "s;$HOME;~;")"
echo " => Libraries: $(echo "$libraries" | sed "s;$HOME;~;")"
echo " => Java: $(echo "$java" | sed "s;$HOME;~;")"
echo " => Java Home: $(echo "$java_home" | sed "s;$HOME;~;")"
echo " => Allow All Libraries: $allow_all_libraries"
echo " => Allow Microphone: $allow_microphone"
echo " => Allow Multiplayer: $allow_multiplayer"
echo
echo "=============================================="

exec sandbox-exec -f "$profile" \
  -Dminecraft="$minecraft" \
  -Dassets="$assets" \
  -Dlibraries="$libraries" \
  -Djava="$java" \
  -Djava_home="$java_home" \
  -Dclasspath="$classpath" \
  -Dnative_dir="$native_dir" \
  -Dallow_all_libraries="$allow_all_libraries" \
  -Dallow_microphone="$allow_microphone" \
  -Dallow_multiplayer="$allow_multiplayer" \
  -D_HOME="$HOME" \
  "$@"

exit 1
