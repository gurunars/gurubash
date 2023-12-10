CMD=$(which brew)

if [ -z "$CMD" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew is already installed"
fi
