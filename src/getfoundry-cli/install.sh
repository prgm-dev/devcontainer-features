#!/bin/sh
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export FOUNDRY_DIR=${FOUNDRY_DIR-"/usr/local/share/foundry"}

SCRIPT_URL="https://foundry.paradigm.xyz"

echo "Downloading Foundry install script from '$SCRIPT_URL'..."
curl -L $SCRIPT_URL | bash
${FOUNDRY_DIR}/bin/foundryup
echo "Adding Foundry to PATH..."
echo "PATH=\"\$PATH:${FOUNDRY_DIR}/bin\"" >>/etc/profile.d/foundry_path.sh
echo >>/etc/bash.bashrc
echo "# Add Foundry to PATH" >>/etc/bash.bashrc
echo "PATH=\"\$PATH:${FOUNDRY_DIR}/bin\"" >>/etc/bash.bashrc
echo >>/etc/bash.bashrc

echo "Foundry has been installed to '$FOUNDRY_DIR'."

BASH_COMPLETION_DIR=$(pkg-config --variable=completionsdir bash-completion)
if [ -z "$BASH_COMPLETION_DIR" ]; then
    echo "bash-completion is not installed. Skipping foundry bash-completions..."
else
    echo "Adding bash-completions for Foundry..."
    for cmd in forge cast anvil; do
        ${FOUNDRY_DIR}/bin/$cmd completions bash >${BASH_COMPLETION_DIR}/$cmd
    done
    echo "Bash-completions for Foundry have been installed to '$BASH_COMPLETION_DIR'."
fi
