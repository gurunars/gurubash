Setup bash settings

On Ubuntu, first:

    sudo apt install -y git make

Then:

    git clone https://github.com/gurunars/gurubash.git ~/.gurubash
    cd ~/.gurubash
    make

`make` installs `core/` only. Extensions come when asked for:

    make aws.install

To load an extension in every shell, name it in
`~/.config/gurubash/default-extensions`, one per line.
