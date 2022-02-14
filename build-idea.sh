#!/usr/bin/env bash
# shellcheck disable=SC2034

set -o errexit -o errtrace -o nounset -o pipefail

# shellcheck disable=SC2155
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly BASE_IMAGE_NAME='localhost/fedora-toolbox' \
         BASE_IMAGE_VERSION='35-custom'
readonly BUILD_IMAGE_NAME='localhost/fedora-toolbox' \
         BUILD_IMAGE_VERSION='35-idea'

readonly INTELLIJ_DOWNLOAD_URL='https://download.jetbrains.com/product?code=IU&distribution=linux&latest'
readonly INTELLIJ_EXTRACT_DIR='/opt/idea'

readonly -a PACKAGES=(
  gnome-themes-extra
  ShellCheck
  jq
)

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap.sh"

if [[ ${#PACKAGES[@]} -gt 0 ]]
then :dnf install "${PACKAGES[@]}"
fi

:run sh -s -- "$INTELLIJ_DOWNLOAD_URL" "$INTELLIJ_EXTRACT_DIR" <<'EOS'
mkdir -p "$2" && \
curl --location --silent "$1" \
  | tar --extract --gzip --directory="$2" --strip-components=1 --verbose
EOS
