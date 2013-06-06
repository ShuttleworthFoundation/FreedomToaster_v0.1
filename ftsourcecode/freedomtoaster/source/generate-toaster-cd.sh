#!/bin/sh 
################################################################################
# Purpose: Create a Freedom Toaster Installation CD
# Inputs  : Ubuntu (cd, main, restricted, universe), Freedom Toaster Subversion Repository
# Output : Creates Freedom Toaster ISO and can optionally burn to CD (one blank CD required)
# Remarks: Run script on an Ubuntu 5.10 server, with admin account as su
# Depends: subversion dpkg-scanpackages cdrecord mkisofs
# License: GPL (http://www.gnu.org/)
# Created: 2006/05/19 Sean Wheller (sean@inwords.co.za)
################################################################################

# Uncomment and replace value of http_proxy as and when required.
# export http_proxy="http://cache.uct.ac.za:8080/"

# The Project SVN Revision Control System

repos=svn://edison.tsf.org.za/freedomtoaster

# The Stable Version Number
SVNVERSION='trunk'

# The ISO file name to generate
ISOFILE=freedomtoaster-ubuntu-5.10_v3.0.iso

############################
# Create directories

mkdir iso || true

mkdir iso/ftpackages || true

############################
# Download the packages

if [ ! -f ./PackageList ]; then
	svn cat $repos/$SVNVERSION/source/PackageList > ./PackageList
fi	
apt-get -d -y --force-yes --reinstall install `sed -e '/^#/d' PackageList`

############################
# copy packages to ftpackages directory
cp /var/cache/apt/archives/*.* iso/ftpackages/ 

############################
# the above does not always get the upgrades etc needed,
# so we include a definitive copy from a working toaster
if [ -d ./completeFTpackages ]; then
	cp -r ./completeFTpackages/*.* iso/ftpackages/ 
fi


############################ 
# Create Package List

dpkg-scanpackages iso/ /dev/null | gzip -c -9 > iso/Packages.gz

############################ 
# Get custom firefox, .mozilla with custom r-kiosk and egalax deb

cd iso/

#wget -c http://learnlinux.tsf.org.za/ft/dotmozilla.tar.gz

wget -c http://learnlinux.tsf.org.za/ft/firefox-1.6a1.en-US.linux-i686.tar.bz2

#wget -c http://www.egalax.com.tw/drivers/ubuntu5.1.tar.gz

cd ..

############################  
# Get Freedom Toaster Scripts and Application

svn export $repos/$SVNVERSION/source iso/ --force

############################  
# Create the ISO Image

mkisofs -o $ISOFILE -l -R -L -V "Freedom Toaster - Vol I" -P "http://www.freedomtoaster.org" -p "Freedom Toaster Install CD V3.0" -A "Freedom Toaster ($SVNVERSION)" iso/

echo "Done"
