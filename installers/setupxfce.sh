#!/usr/bin/env bash

# #############################################################################
# Globals

export APTPROG=apt-get; which apt >/dev/null 2>&1 && export APTPROG=apt
export RPMPROG=yum; which dnf >/dev/null 2>&1 && export RPMPROG=dnf
export RPMGROUP="yum groupinstall"; which dnf >/dev/null 2>&1 && export RPMGROUP="dnf group install"

# #############################################################################
# Main

if egrep -i -q '(centos|fedora|oracle|red *hat).* 6' /etc/*release*

  echo ${BASH_VERSION:+-e} "\n==> XFCE..."
  sudo $RPMGROUP desktop "general purpose desktop" "x window system"
  sudo $RPMGROUP xfce

  echo ${BASH_VERSION:+-e} "\n==> XFCE fonts..."
  sudo $RPMPROG -y install xorg-x11-fonts-Type1 xorg-x11-fonts-misc

elif egrep -i -q 'debian|ubuntu' /etc/*release* ; then

  echo ${BASH_VERSION:+-e} "\n==> XFCE..."
  sudo $APTPROG install xfce4 desktop-base thunar-volman tango-icon-theme xfce4-notifyd xscreensaver light-locker xfce4-volumed tumbler xfwm4-themes

  echo ${BASH_VERSION:+-e} "\n==> XFCE plugins..."
  sudo $APTPROG install xfce4-clipman-plugin xfce4-mount-plugin xfce4-places-plugin xfce4-terminal xfce4-timer-plugin
fi