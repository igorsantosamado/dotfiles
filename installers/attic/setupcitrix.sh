#!/usr/bin/env bash

PROGNAME=setupcitrix

if ! (uname | grep -i -q linux) ; then echo "$PROGNAME: SKIP: Linux supported only" ; exit ; fi
if [ -e /opt/Citrix/ICAClient/selfservice ] ; then echo "$PROGNAME: SKIP: Already installed" ; exit ; fi

echo "$PROGNAME: INFO: Citrix setup started"
echo "$PROGNAME: INFO: \$0='$0'; \$PWD='$PWD'"

# Sources:
# https://help.ubuntu.com/community/CitrixICAClientHowTo

# Remark SSL error 47, download Linux Receiver 13.4, source:
# https://discussions.citrix.com/topic/385459-ssl-error-with-135-works-with-134/

# #############################################################################
# Globals

CITRIX_VERSION=${1:-13.4}
CITRIX_MAJOR_VERSION=${CITRIX_VERSION%%.*}
CITRIX_MINOR_VERSION=${CITRIX_VERSION##*.}
CITRIX_DOWNLOAD_URL="https://www.citrix.com.br/downloads/citrix-receiver/\
legacy-receiver-for-linux/receiver-for-linux-latest-\
${CITRIX_MAJOR_VERSION}-${CITRIX_MINOR_VERSION}.html"

# #############################################################################
# Prep filesystem

rm -r -f -v "$HOME"/.ICAClient
sudo rm -f -r -v /opt/setupcitrix/*
sudo mkdir -p /opt/setupcitrix
sudo chmod -v 777 /opt/setupcitrix

cd /opt/setupcitrix
echo "PWD:"
pwd

# #############################################################################
# Prep download the package

while ! ls -1 "$HOME/Downloads"/*linuxx64* >/dev/null 2>&1 ; do

  echo "$PROGNAME: INFO: Please go download the linuxx64...tar.gz package,"
  echo "$PROGNAME: INFO: ... and place it in '$HOME/Downloads'..."
  echo
  echo "$PROGNAME: INFO: Opening the browser for you at '$CITRIX_DOWNLOAD_URL'..."
  echo "$PROGNAME: IMPORTANT: Select the >> tarball << option..."

  (firefox "$CITRIX_DOWNLOAD_URL" >/dev/null 2>&1 \
    || google-chrome "$CITRIX_DOWNLOAD_URL" >/dev/null 2>&1) & disown

  sleep 30

  echo "If still downloading then just ignore this prompt..."
  read -p "Press ENTER either if download has finished or to reopen the URL in a browser..." dummy
done

# #############################################################################
# Main

if sudo tar xzvf $(ls -1 "$HOME/Downloads"/*linuxx64* | tail -n 1) ; then
  echo "$PROGNAME: FATAL: There was some error extracting the tarball." 1>&2
fi

sudo /opt/setupcitrix/setupwfc || exit $?

# #############################################################################
# Post-install certificates

if egrep -i -q -r 'ubuntu' /etc/*release ; then
  # SSL certificates from Firefox
  sudo cp -v \
    /usr/share/ca-certificates/mozilla/* \
    /opt/Citrix/ICAClient/keystore/cacerts/
  sudo c_rehash /opt/Citrix/ICAClient/keystore/cacerts/

  # Firefox fix
  sudo rm -f \
    /usr/lib/mozilla/plugins/npwrapper.npica.so \
    /usr/lib/firefox/plugins/npwrapper.npica.so
  sudo rm -f /usr/lib/mozilla/plugins/npica.so
  sudo ln -s \
    /opt/Citrix/ICAClient/npica.so \
    /usr/lib/mozilla/plugins/npica.so
  sudo ln -s \
    /opt/Citrix/ICAClient/npica.so \
    /usr/lib/firefox-addons/plugins/npica.so

elif egrep -i -q -r 'centos|fedora|oracle|red *hat' /etc/*release ; then
  curl -kLSfo /tmp/cacert-roots-symantec.zip \
    http://www.symantec.com/content/en/us/enterprise/verisign/roots/roots.zip
  unzip /tmp/cacert-roots-symantec.zip -d "$HOME"
  sudo cp -a "$HOME"/VeriSign\ Root\ Certificates/Generation\ 5\ \(G5\)\ PCA/VeriSign\ Class\ 3\ Public\ Primary\ Certification\ Authority\ -\ G5.* \
    /opt/Citrix/ICAClient/keystore/cacerts/

  sudo c_rehash /opt/Citrix/ICAClient/keystore/cacerts/
else
  echo "$PROGNAME: SKIP: No ca-cert setup supported for this distro."
  exit 0
fi

# Chrome mime type for ICAClient
# xdg-mime default wfica.desktop application/x-ica

# #############################################################################
# Final sequence

echo "$PROGNAME: COMPLETE: Citrix setup"
exit
