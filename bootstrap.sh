# shellcheck shell=bash

if [[ ! "${SCRIPT_DIR:+"x"}" ]]
then
  printf -- '%s\n' 'SCRIPT_DIR is not defined, exiting.' 1>&2
  exit 1
fi

if [[ ! -r "${SCRIPT_DIR}/bootstrap/bootstrap.sh" ]]
then
  printf -- '%s\n' "${SCRIPT_DIR}/bootstrap/bootstrap.sh is not readable, exiting." 1>&2
  exit 1
fi

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/bootstrap/bootstrap.sh"

if [[ ! "${BASE_IMAGE_NAME:+"x"}" ]]
then :die 'BASE_IMAGE_NAME is not defined, exiting.'
fi

if [[ ! "${BASE_IMAGE_VERSION:+"x"}" ]]
then :die 'BASE_IMAGE_VERSION is not defined, exiting.'
fi

if [[ ! "${BUILD_IMAGE_NAME:+"x"}" ]]
then :die 'BUILD_IMAGE_NAME is not defined, exiting.'
fi

if [[ ! "${BUILD_IMAGE_VERSION:+"x"}" ]]
then :die 'BUILD_IMAGE_VERSION is not defined, exiting.'
fi

readonly BASE_IMAGE="${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}"
readonly BUILD_IMAGE="${BUILD_IMAGE_NAME}:${BUILD_IMAGE_VERSION}"

:log "Base Image: ${BASE_IMAGE}" \
     "Build Image: ${BUILD_IMAGE}"

# shellcheck disable=SC2155
readonly BUILDAH_CONTAINER="$(uuidgen)"

:log "Buildah Container: ${BUILDAH_CONTAINER}"

function :run () {
  :log '' "> RUN ${*}" ''
  buildah run -- "$BUILDAH_CONTAINER" "$@"
}

function :dnf () {
  :run dnf --assumeyes "$@"
}

function :cleanup () {
  :log '' 'Cleaning up...' ''

  :dnf autoremove
  :dnf clean all

  :log '' 'Squashing Buildah Container...' ''
  buildah commit --squash "$BUILDAH_CONTAINER" "$BUILD_IMAGE"

  :log '' 'Removing Buildah Container...' ''
  buildah rm "$BUILDAH_CONTAINER"
}

trap :cleanup EXIT

:log '' 'Starting Buildah Container...' ''
buildah from --name "$BUILDAH_CONTAINER" "$BASE_IMAGE"

if [[ "$(type -t :init)" == 'function' ]]
then :init "$BUILDAH_CONTAINER"
fi

:dnf upgrade
