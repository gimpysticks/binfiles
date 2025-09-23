echo -e $USERPASS|sudo -S apt-get -o Acquire::ForceIPv4=true update
echo -e $USERPASS|sudo -S apt-get -y upgrade
echo -e $USERPASS|sudo -S apt-get -y dist-upgrade
