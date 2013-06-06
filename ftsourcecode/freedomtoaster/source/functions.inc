. config.inc

function upgradeToaster {
   pushd $BASEPATH
   sudo tar -zxf $OLDPWD/toaster-$NEWVER.tar.gz
   chown -R www-data: $BASEPATH
   echo Enter any value to continue...
   read JNK
   popd
}
function getUnmountedDVDRW {
# Assuming the script is running from one CDROM, find any other that is not mounted
# to load the update cds into.  Also, ensure it can do DVD...
   DRIVES=($(grep -o /dev/hd. $BASEPATH/cgi-bin/config.pl))
   COUNT=0
   for DRIVE in ${DRIVES[*]}; do
      if [ `mount | grep -ci $DRIVE` -gt 0 ]; then
         umount $DRIVE
      fi
      if [ `cdrecord dev=$DRIVE -checkdrive 2>/dev/null | grep -ic DVD` -gt 0 ]; then
         DVDDRIVES[$COUNT]=$DRIVE
         COUNT=$COUNT+1
      fi
   done
   for DRIVE in ${DVDDRIVES[*]}; do
      echo $DRIVE is a DVD
   done
}
function updateDistros {
# first, copy the directory structures and XML files and images 
   pushd $ISODIR
   tar -zxf $OLDPWD/NewDistros.tar.gz
   chown -R www-data: $ISODIR
   popd
   pushd $BASEPATH
   tar -zxf $OLDPWD/NonCodeUpdates.tar.gz
   chown -R www-data: $BASEPATH
   echo Press Enter to continue...
   read JNK
   popd

# now, invoke an update script from /tmp to prompt for ISO DVDs etc
   exec ./ContentUpdate
}
function getDVDRWPATH {
   if [ ${DVDDRIVES}x = x ]; then
      echo No DVDDRIVES are set
      return
   fi
   DVDRWPATH=$(grep $DVDDRIVES /etc/fstab | tr -s ' ' | cut -d' ' -f2)
}
function crackArchive {
   pushd $BASEPATH
   tar -zxvf $OLDPWD/$1
   chown -R www-data: $BASEPATH
   popd
}
function confirmLocationParameter {
# $1 = full path to file where parameter is set
# $2 = name of bash variable holding location
# $3 = name of file or directory inside expected location

   myChoice=''
   until [ x$myChoice = 'xA' -o x$myChoice = 'xa' ]; do 
      . $1
      eval myLocation=\$$2
      if [ -e $myLocation ]; then
         if [ -e $myLocation/$3 ]; then
            echo "$2 is : $myLocation (confirmed)"
         else
            echo "$2 is : $myLocation"
         fi
      else
         echo "$2 not found : $1 says $myLocation"
      fi
      echo "A)ccept or E)dit"
      read myChoice
      if [ x$myChoice = 'xE' -o x$myChoice = 'xe' ]; then
         echo "Enter the new path (no trailing /):"
         read NEWPATH
         perl -pi -e "s#$myLocation#$NEWPATH#g" $1
      fi
   done
}
function confirmROOTUser {
   if [ ! `whoami` = 'root' ]; then
      echo You need to be the root user to run this script, try \'sudo $0\'
      exit
   fi
}
function shiftENVIRONMENT {
   WD=$(mktemp -d /tmp/toaster.XXXXXX)
   cp * $WD/
   cd $WD
   exec ./InstallScript
}
