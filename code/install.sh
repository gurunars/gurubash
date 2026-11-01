#!/bin/bash

set -e

OS=${OS:-$("${GURUBASH}/pkg-manager/get-os.sh")}

# Where VS Code reads its user config differs per OS.
if [ "${OS}" = "mac" ]; then
    VS_PATH="${HOME}/Library/Application Support/Code/User"
else
    VS_PATH="${HOME}/.config/Code/User"
fi

mkdir -p "${VS_PATH}"

# Link a repo file into VS Code's config dir. A regular file that is already
# there is moved to <name>.bak first, and an existing .bak is never replaced.
function link_config {
    local target="${VS_PATH}/$1"
    if [ -e "${target}" ] && [ ! -L "${target}" ]; then
        if [ -e "${target}.bak" ]; then
            echo "code: ${target}.bak exists; leaving ${target} alone" >&2
            return 0
        fi
        mv "${target}" "${target}.bak"
    fi
    ln -f -s "${GURUBASH}/code/$1" "${target}"
}

link_config keybindings.json
link_config settings.json

# extensions: only the ones missing are fetched

EXTENSIONS="
ms-vscode.makefile-tools
tamasfe.even-better-toml
lextudio.restructuredtext
ms-azuretools.vscode-docker
dbaeumer.vscode-eslint
ryuta46.multi-command
ms-python.python
tomoki1207.pdf
docsmsft.docs-markdown
orta.vscode-jest
davidanson.vscode-markdownlint
stylelint.vscode-stylelint
"

if command -v code >/dev/null 2>&1; then
    INSTALLED=$(code --list-extensions | tr '[:upper:]' '[:lower:]')
    for extension in ${EXTENSIONS}; do
        if echo "${INSTALLED}" | grep -qxF "$(echo "${extension}" | tr '[:upper:]' '[:lower:]')"; then
            echo "${extension} is already installed"
        else
            code --install-extension "${extension}"
        fi
    done
fi
