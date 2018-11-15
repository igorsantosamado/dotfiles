#!/usr/bin/env bash

echo
echo "################################################################################"
echo "Setup Chrome browser..."

# #############################################################################
# Globals

export APTPROG=apt-get; which apt >/dev/null 2>&1 && export APTPROG=apt
export RPMPROG=yum; which dnf >/dev/null 2>&1 && export RPMPROG=dnf
export RPMGROUP="yum groupinstall"; which dnf >/dev/null 2>&1 && export RPMGROUP="dnf group install"

# #############################################################################
# Main

if egrep -i -q -r '(centos|fedora|oracle|red *hat).* 7' /etc/*release ; then

  cat <<EOF | sudo tee /etc/yum.repos.d/google-x86_64.repo
[google64]
name=Google - x86_64
baseurl=http://dl.google.com/linux/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
  sudo $RPMPROG install -y google-chrome-stable

elif egrep -i -q -r 'debian|ubuntu' /etc/*release ; then

  curl -LSfs "https://dl-ssl.google.com/linux/linux_signing_key.pub" | sudo apt-key add -

  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
  if [ "$(uname -p)" = "x86_64" ] ; then
    sudo sed -i -e 's/deb http/deb [arch=amd64] http/' '/etc/apt/sources.list.d/google-chrome.list'
  fi

  sudo $APTPROG update
  sudo $APTPROG install -y google-chrome-stable
else
  echo "${PROGNAME:+$PROGNAME: }SKIP: OS not supported." 1>&2
  exit
fi

# #############################################################################
# Finish

echo "FINISHED Chrome browser setup"
echo
