sudo apt install -y python-is-python3 python3-pip
sudo ln -s /usr/bin/pip3 /usr/bin/pip
curl -sSL https://install.python-poetry.org | python3 -
poetry completions bash > $HOME/.local/share/bash-completion/completions/poetry
