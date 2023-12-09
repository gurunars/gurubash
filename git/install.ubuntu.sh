CMD=$(which git)
DIR=$(cd $(dirname -- "$0") && pwd)

if [ -z "$CMD" ]; then
    sudo apt install git
else
    echo "GIT is already installed"
fi

bash $DIR/install.sh
