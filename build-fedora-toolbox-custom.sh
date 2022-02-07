#!/usr/bin/env bash
# shellcheck disable=SC2034

set -o errexit -o errtrace -o nounset -o pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly BASE_IMAGE_NAME='registry.fedoraproject.org/fedora-toolbox' \
         BASE_IMAGE_VERSION='35'
readonly BUILD_IMAGE_NAME='localhost/fedora-toolbox' \
         BUILD_IMAGE_VERSION='35-custom'

readonly -a PACKAGES=()

function :init () {
  :run tee --append /etc/dnf/dnf.conf < <(
    :println                    \
      fastestmirror=True        \
      deltarpm=True             \
      max_parallel_downloads=10
  )
}

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap.sh"

:dnf group install 'Development Tools'

if [[ ${#PACKAGES[@]} -gt 0 ]]
then :dnf install "${PACKAGES[@]}"
fi
