#!/usr/bin/env bash
# shellcheck disable=SC2034

set -o errexit -o errtrace -o nounset -o pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly BASE_IMAGE_NAME='localhost/fedora-toolbox-38' \
         BASE_IMAGE_VERSION='latest'
readonly BUILD_IMAGE_NAME='localhost/fedora-toolbox-38-code' \
         BUILD_IMAGE_VERSION='latest'

readonly VSCODE_REPO='https://packages.microsoft.com/yumrepos/vscode' \
         VSCODE_REPO_KEY='https://packages.microsoft.com/keys/microsoft.asc'

readonly -a PACKAGES=(
  code
  gnome-themes-extra
  ShellCheck
  jq
)

function :init () {
  :run rpm --import "$VSCODE_REPO_KEY"

  :run tee /etc/yum.repos.d/vscode.repo < <(
    :println '[code]'           \
      name='Visual Studio Code' \
      baseurl="$VSCODE_REPO"    \
      enabled=1                 \
      gpgcheck=1                \
      gpgkey="$VSCODE_REPO_KEY"
  )
}

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap.sh"

if [[ ${#PACKAGES[@]} -gt 0 ]]
then :dnf install "${PACKAGES[@]}"
fi
