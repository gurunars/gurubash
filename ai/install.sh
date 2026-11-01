#!/bin/bash

set -e

# The model name lives in ai/loader only.
. "${GURUBASH}/ai/loader"

if [ "${OS}" == "mac" ]; then
    APP_NAME=ollama "$INSTALL"
elif ! command -v ollama &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "ollama is already installed"
fi

if ollama list | awk 'NR > 1 { print $1 }' | grep -qxF "${AI_MODEL}"; then
    echo "${AI_MODEL} is already pulled"
else
    ollama pull "${AI_MODEL}"
fi
