BASEPATH='/srv/www/kiosk'
# live toasters are '/SRV/WWW/KIOSK'
CGIPATH="$BASEPATH/cgi-bin"
CONFIG="$CGIPATH/config.pl"
ISODIR=$(grep main::IsoDir $CONFIG | sed "s/.*'\([^']*\)'.*/\1/")
OLDVER=$(grep main::Version $CONFIG | sed "s/.*'\([^']*\)'.*/\1/")
NEWVER=2.0
VERSION=0.2
