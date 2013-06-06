#!/bin/bash
################################################################################
# Purpose : Set Configuration of the Freedom Toaster
# Remarks : This must live in cgi-bin/upgrade/setconfig.sh and is executed as 
#           root by the administrator to check/set/fix configuration settings
#           This script is also called by the 'InstallScript' script before
#           doing a system or content upgrade to ensure that the paths and 
#           other settings are correct
# Created : Charles Oertel (2005/11/06) Charles@FineBushPeople.net
# License : GPL
################################################################################
. functions.inc
# Confirm that we are root before going on
confirmROOTUser
#
### Find the system paths and confirm the settings...
#
# BASEPATH (/srv/www/kiosk, /var/www/kiosk, or other)
confirmLocationParameter 'config.inc' 'BASEPATH' 'index3.html'
# ISODIR   (/srv/isos, /isos, or other)
confirmLocationParameter 'config.inc' 'ISODIR' 'ubuntu'
# CGIPATH  ($BASEDIR/cgi-bin or other
confirmLocationParameter 'config.inc' 'CGIPATH' 'closeCD.pl'
# CONFIG   ($CGIPATH/config.pl or else)
confirmLocationParameter 'config.inc' 'CONFIG' 

### List CD burners and check they are in $CGIDIR/config.pl
if [ ! -e /etc/rc.boot ]; then
   mkdir /etc/rc.boot
fi
if [ ! -e /etc/rc.boot/setHDparms ]; then
   echo '#!/bin/bash' > /etc/rc.boot/setHDparms
   echo 'for CDDevice in `dmesg | egrep "CD|DVD" | grep -o hd. | sort -u`' >> /etc/rc.boot/setHDparms
   echo 'do' >> /etc/rc.boot/setHDparms
   echo 'hdparm -c1 -d1 -u1 -k1 /dev/$CDDevice' >> /etc/rc.boot/setHDparms
   echo 'done' >> /etc/rc.boot/setHDparms
fi
chmod a+x /etc/rc.boot/setHDparms
/etc/rc.boot/setHDparms

echo Inject into the perl config file, new values for the LogFile and ToasterName:
if [ ! `grep 'main::LogFile' $CONFIG` ]; then
   echo "\$main::LogFile = '/home/kiosk/toasting.log'; into $CONFIG" 
   echo "\$main::LogFile = '/home/kiosk/toasting.log';" >> $CONFIG
fi
if [ ! `grep 'main::BasePath' $CONFIG` ]; then
   echo "\$main::BasePath = '$BASEPATH'; into $CONFIG" 
   echo "\$main::LogFile = '$BASEPATH';" >> $CONFIG
fi
if [ ! `grep 'main::ToasterName' $CONFIG` ]; then
   echo "Enter a unique short name with no spaces or commas, for this toaster (to help identify log entries):"
   read KY
   echo "\$main::ToasterName = '$KY'; into $CONFIG" 
   echo "\$main::ToasterName = '$KY';" >> $CONFIG
fi

if [ `grep -ic 'udf,' /etc/fstab` ]; then
   echo 'Removing udf filesystem from /etc/fstab entries:' 
   grep -i 'udf' /etc/fstab
   perl -pi -e 's/udf,//i' /etc/fstab
   echo 'Your udf entries in /etc/fstab are these:'
   grep -i udf /etc/fstab
   echo 'Your cd/dvd entries in /etc/fstab are:'
   grep -i cdrom /etc/fstab
fi
echo Set permissions on /home/kiosk to world-writable
chmod -R a+w /home/kiosk

echo Set ownership of isos and web directories to www-data
chown -R www-data: $BASEPATH
chown -R www-data: $ISODIR
