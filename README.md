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
`~/.config/gurubash/default-extensions`, one per line. Nothing is loaded by
default, and no install creates that file. Extensions: `ai`, `android`, `aws`,
`chrome`, `code`, `go`, `java`, `python`. A tool that was on your PATH before
(say `go`, or Android's platform-tools) is missing until you load its
extension: `make go.install`, then add `go` to the file.
