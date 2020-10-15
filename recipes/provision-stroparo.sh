#!/usr/bin/env bash

: ${PROGNAME:=provision-stroparo.sh}
: ${RUNR_DIR:=${RUNR_DIR:-${PWD}}}

REPO_BASE_BB="stroparo@bitbucket.org/stroparo"
REPO_BASE_GH="stroparo@github.com/stroparo"
PROVISION_DEVEL="golang nodejs python rust"


if [ ${PROGNAME} != 'provision-stroparo.sh' ] ; then
  echo ; echo ; echo "${PROGNAME:+$PROGNAME: }INFO: provision-stroparo.sh steps from this point on..." 1>&2
  echo '...' ; echo ; echo
fi


# Recipes:
if [ -z "${PROVISION_OPTIONS}" ] ; then
  export PROVISION_OPTIONS="base gui xfce brave ${PROVISION_DEVEL}"
else
  export PROVISION_OPTIONS="nodevel ${PROVISION_DEVEL}"
fi
bash "${RUNR_DIR}"/recipes/provision.sh
bash "${RUNR_DIR}"/recipes/dotfiles.sh
bash "${RUNR_DIR}"/recipes/git.sh

# Daily Shells setups:
source "${RUNR_DIR:-.}"/helpers/dsenforce.sh
if ! (dsplugin.sh "${REPO_BASE_BB}/ds-stroparo" || dsplugin.sh "${REPO_BASE_GH}/ds-stroparo") ; then exit 1 ; fi
if ! (dsplugin.sh "${REPO_BASE_BB}/ds-js" || dsplugin.sh "${REPO_BASE_GH}/ds-js") ; then
  echo "${PROGNAME:+$PROGNAME: }WARN: ds-js Daily Shells plugin for JavaScript was not installed." 1>&2
fi
bash "${DS_HOME:-$HOME/.ds}"/scripts/dsconfgit.sh
bash "${DS_HOME:-$HOME/.ds}"/scripts/selects-python-stroparo.sh


if [ ${PROGNAME} != 'provision-stroparo.sh' ] ; then
  echo ; echo ; echo '...'
  echo "${PROGNAME:+$PROGNAME: }INFO: provision-stroparo.sh steps COMPLETE" 1>&2
  echo ; echo
fi
