#!/bin/bash
# --
# https://github.com/dqft/terraform.sh

# Searches for files from the given location to its parent folders
_reverse_lookup() {
  [[ "$1" == */* ]] && _reverse_lookup $(echo "$1" | sed 's#\(.*\)/.*#\1#') $2
  test -e "$1/$2" && echo "$1/$2"
}

test -e ~/.env && _env_files=~/.env
_env_files=${_env_files} $(_reverse_lookup $PWD .env)

# Sets a variable from its value in a file or from its given fallback value
_env() {
  result=
  for f in ${_env_files}; do
    from_file=$(egrep "^$1=" $f | awk -F= '{print $2}')
    result=${from_file:-$result}
  done
  eval $1=${result:-$2}
}

# Returns command arguments for reproducing host user's environment
_local_user_options() {
  _env TERRAFORM_USER  $(id -u)
  _env TERRAFORM_GROUP $(id -g)
  echo "-u ${TERRAFORM_USER}:${TERRAFORM_GROUP}"

  _env TERRAFORM_HOME $(eval echo ~$(id -un))
  echo "-v ${TERRAFORM_HOME}:${TERRAFORM_HOME}"
  echo "-e HOME=${TERRAFORM_HOME}"
}

# Returns command arguments for supporting host's Docker daemon in container
_local_docker_options() {
  _env TERRAFORM_HOST_DOCKER_SUPPORT true
  [[ "${TERRAFORM_HOST_DOCKER_SUPPORT}" != "true" ]] && return

  _env TERRAFORM_HOST_DOCKER_SOCKET /var/run/docker.sock
  echo "-v ${TERRAFORM_HOST_DOCKER_SOCKET}:/var/run/docker.sock"

  _env TERRAFORM_HOST_DOCKER_PLATFORM # default value is null
  [[ ! -z "${TERRAFORM_HOST_DOCKER_PLATFORM}" ]] && echo "--platform ${TERRAFORM_HOST_DOCKER_PLATFORM}"
}

_env TERRAFORM_VERSION      latest
_env TERRAFORM_DOCKER_IMAGE hashicorp/terraform:${TERRAFORM_VERSION}

docker run --rm -it \
  -v ${PWD}:${PWD} -w ${PWD} \
  $(for f in ${_env_files}; do echo "--env-file $f"; done) \
  $(_local_user_options) \
  $(_local_docker_options) \
  ${TERRAFORM_DOCKER_IMAGE} \
  "$@"