#!/usr/bin/env bash

PROGNAME="apps-el.sh"

if ! egrep -i -q -r 'cent *os|fedora|oracle|red *hat' /etc/*release ; then echo "${PROGNAME}: SKIP: EL supported only" 1>&2 ; exit ; fi

echo "$PROGNAME: INFO: EL Enterprise Linux selections installation"
echo "$PROGNAME: INFO: \$0='$0'; \$PWD='$PWD'"

# #############################################################################
# Globals

# System installers
export RPMPROG=yum; which dnf >/dev/null 2>&1 && export RPMPROG=dnf
export RPMGROUP="yum groupinstall"; which dnf >/dev/null 2>&1 && export RPMGROUP="dnf group install"
export INSTPROG="$RPMPROG"

# #############################################################################
# Helpers


if [ -f ~/.ds/ds01tests.sh ] ; then
  . ~/.ds/ds01tests.sh
else
  _is_el () { egrep -i -q -r '(cent *os|oracle|red *hat)' /etc/*release ; }
  _is_el6 () { egrep -i -q -r '(cent *os|oracle|red *hat).* 6' /etc/*release ; }
  _is_el7 () { egrep -i -q -r '(cent *os|oracle|red *hat).* 7' /etc/*release ; }
  _is_fedora () { egrep -i -q -r 'fedora' /etc/*release ; }
fi


_install_epel_packages () {
  typeset filestamp="$(date '+%Y%m%d-%OH%OM%OS')"

  for package in "$@" ; do
    if yum list installed "${package}" >/dev/null 2>&1 ; then
      echo "$PROGNAME: SKIP: Package '${package}' already installed..."
    else
      echo "$PROGNAME: INFO: Installing '${package}'..."
      if ! (sudo "${INSTPROG}" install -y --enablerepo=epel "${package}" 2>&1 | tee "/tmp/pkg-install-${filestamp}-${package}.log") ; then
        echo "${PROGNAME:+$PROGNAME: }WARN: There was an error installing packages - see '/tmp/pkg-install-${filestamp}-${package}.log'." 1>&2
      fi
    fi
  done
}


_install_packages () {
  typeset filestamp="$(date '+%Y%m%d-%OH%OM%OS')"

  for package in "$@" ; do
    if yum list installed "${package}" >/dev/null 2>&1 ; then
      echo "$PROGNAME: SKIP: Package '${package}' already installed..."
    else
      echo "$PROGNAME: INFO: Installing '${package}'..."
      if ! sudo $INSTPROG install -y "${package}" >/tmp/pkg-install-${filestamp}-${package}.log 2>&1 ; then
        echo "${PROGNAME:+$PROGNAME: }WARN: There was an error installing packages - see '/tmp/pkg-install-${filestamp}-${package}.log'." 1>&2
      fi
    fi
  done
}


_install_rpm_groups () {
  typeset filestamp="$(date '+%Y%m%d-%OH%OM%OS')-${RANDOM}"
  if ! sudo $RPMGROUP -y "$@" >/tmp/rpm-group-install-err-${filestamp}.log 2>&1 ; then
    echo "${PROGNAME:+$PROGNAME: }WARN: There was an error installing groups - see '/tmp/rpm-group-install-err-${filestamp}.log'." 1>&2
  fi
}


# #############################################################################
# Main

# EPEL extra packages
if ! _is_fedora ; then
  echo "PROGNAME: INFO: EPEL - Extra Packages for Enterprise Linux..." # https://fedoraproject.org/wiki/EPEL
  if _is_el7 ; then
    _install_packages https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  else
    _install_packages epel-release.noarch
  fi
fi

# New HOSTNAME setup, if any
if [ -n "$NEWHOSTNAME" ] ; then
  echo "PROGNAME: INFO: Setting up hostname to '${NEWHOSTNAME}'..." 1>&2
  sudo hostnamectl set-hostname "${NEWHOSTNAME:-andromeda}"
fi

# Package indexing setup
sudo yum makecache fast

echo "PROGNAME: INFO: EL base packages..."
_install_packages deltarpm less unzip zip zsh
_install_packages curl lftp rsync wget
_install_packages sqlite libdbi-dbd-sqlite
_install_epel_packages mosh p7zip p7zip-plugins lzip cabextract unrar the_silver_searcher
which tmux >/dev/null 2>&1 || _install_packages tmux

echo "PROGNAME: INFO: EL devel packages..."
sudo $RPMGROUP -q -y --enablerepo=epel 'Development Tools'
_install_epel_packages jq
_install_packages ctags make perl perl-devel perl-ExtUtils-Embed
# _install_packages golang
# _install_packages ruby ruby-devel

echo "PROGNAME: INFO: EL security packages..."
_install_packages gnupg pwgen oathtool oath-toolkit
_install_packages setroubleshoot-server selinux-policy-devel # SELinux

echo "PROGNAME: INFO: EL system packages..."
_install_packages yum-utils

# #############################################################################
# Final sequence

echo "$PROGNAME: COMPLETE: EL Enterprise Linux selections installation"
exit
