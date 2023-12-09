CMD=$(which git)
DIR=$(cd $(dirname -- "$0") && pwd)

if [ -z "$CMD" ]; then
    echo "Install GIT on mac by hand"
    exit 1
else
    echo "GIT is already installed"
fi

echo $DIR/install.sh

bash $DIR/install.sh
