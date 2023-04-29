#!/usr/bin/env bash
# shellcheck disable=SC2034

set -o errexit -o errtrace -o nounset -o pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly BASE_IMAGE_NAME='localhost/fedora-toolbox-38' \
         BASE_IMAGE_VERSION='latest'
readonly BUILD_IMAGE_NAME='localhost/fedora-toolbox-38-yubikey-manager' \
         BUILD_IMAGE_VERSION='latest'

readonly -a PACKAGES=(
  yubikey-manager
  gnupg2
  gnupg2-smime
  pinentry-curses
  pcsc-lite
  pcsc-lite-libs
)

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap.sh"

if [[ ${#PACKAGES[@]} -gt 0 ]]
then :dnf install "${PACKAGES[@]}"
fi

:run sh -c '_YKMAN_COMPLETE=bash_source ykman >/etc/bash_completion.d/ykman'
