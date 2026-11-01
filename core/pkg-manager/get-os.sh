# Prints the OS name the installers use: `mac`, or `ubuntu` for the whole apt family,
# which is Ubuntu, Debian and anything that declares Debian as its parent. Other Linux
# is refused. OS_RELEASE overrides the file read, so a check can test Debian on any host.
OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
  echo "mac"
elif [ "$OS" = "Linux" ]; then
  family=$(. "${OS_RELEASE:-/etc/os-release}" 2>/dev/null && printf ' %s %s ' "$ID" "${ID_LIKE:-}")
  case "$family" in
    *" ubuntu "* | *" debian "*) echo "ubuntu" ;;
    *) echo "Unknown OS"; exit 1 ;;
  esac
else
  echo "Unknown OS"
  exit 1
fi
