#!/usr/bin/env bash

# #############################################################################
# RedHat

if ! egrep -i -q 'cent ?os|oracle|red ?hat' /etc/*release* ; then
  echo "FATAL: Only Red Hat based distros are allowed to call this script ($0)" 1>&2
  exit 1
fi

PROG=yum
if which dnf >/dev/null 2>&1; then
  PROG=dnf
fi

# #############################################################################
# Sudo check

if ! which sudo ; then
  echo "FATAL: Please log in as root, install and then configure sudo for your user first.." 1>&2
  cat "Suggested commands:" <<EOF
su -
$PROG install sudo
visudo
EOF
  exit 1
fi

# #############################################################################
# Upgrade

echo ${BASH_VERSION:+-e} "\n==> Upgrade all packages? [y/N]\c" ; read answer
[[ $answer = y ]] && sudo $PROG update

# #############################################################################
# Base

sudo $PROG install -y curl less rsync unzip wget zip zsh

# Etc
sudo $PROG install -y lftp mosh
sudo $PROG install -y p7zip p7zip-plugins

# #############################################################################
# Devel

sudo $PROG install -y git tig jq make sqlite tmux

# #############################################################################
# SELinux

sudo $PROG install -y setroubleshoot-server selinux-policy-devel

# #############################################################################
# SilverSearcher Ag
# https://github.com/ggreer/the_silver_searcher

if ! ag --version ; then
  if ! grep -i -q 'fedora' /etc/*release* ; then
    sudo $PROG install -y epel-release.noarch
  fi
  sudo $PROG install -y the_silver_searcher
fi

# #############################################################################
# Specific to the distribution

sudo $PROG install -y yum-utils

# #############################################################################
# Cleanup

