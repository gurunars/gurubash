OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
  echo "mac"
elif [ "$OS" = "Linux" ]; then
  echo "ubuntu"
else
  echo "Unknown OS"
  exit 1
fi
