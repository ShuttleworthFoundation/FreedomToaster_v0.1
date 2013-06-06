#!/bin/sh -e
################################################################################
# Purpose: Downloads ISO files that are the content of the Freedom Toaster
# Inputs  : A good network connection
# Remarks: Run script on freshly installed Fredom Toaster to get content.
# Acknowledge: Many thanks to "Peter Kolbe" <ops@venturenet.co.za> for providing the basis for this script 
# License: GPL (http://www.gnu.org/)
# Created: 2006/05/17 Sean Wheller (sean@inwords.co.za)
################################################################################

# Uncomment and replace value of http_proxy as and when required.
# export http_proxy="http://cache.uct.ac.za:8080/"

# Internet Solutions
PROTOCOL=ftp
FQDN=ftp.is.co.za
FOLDER=mirror

# University of Cape Town
# PROTOCOL=ftp
# FQDN=ftp.leg.uct.ac.za
# FOLDER=pub

# South African Internet Exchange
# PROTOCOL=ftp
# FQDN=ftp.saix.net
# FOLDER=pub

DOWNLOAD=$PROTOCOL://$FQDN/$FOLDER

cd /srv/isos/fedora/FC4/CD
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/4/i386/iso/FC4-i386-disc1.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/4/i386/iso/FC4-i386-disc2.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/4/i386/iso/FC4-i386-disc3.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/4/i386/iso/FC4-i386-disc4.iso

cd /srv/isos/fedora/FC5/CD
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/5/i386/iso/FC-5-i386-disc1.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/5/i386/iso/FC-5-i386-disc2.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/5/i386/iso/FC-5-i386-disc3.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/5/i386/iso/FC-5-i386-disc4.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/fedora.redhat.com/linux/core/5/i386/iso/FC-5-i386-disc5.iso

#cd /srv/isos/ooffice/2.0/CD
#wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.openoffice.org/stable/2.0.2/OOo_2.0.2_Win32Intel_install_wJRE.exe

cd /srv/isos/suse/
cd 9.3/CD
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.suse.com/9.3/iso/SUSE-9.3-Prof-i386-CD1.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.suse.com/9.3/iso/SUSE-9.3-Prof-i386-CD2.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.suse.com/9.3/iso/SUSE-9.3-Prof-i386-CD3.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.suse.com/9.3/iso/SUSE-9.3-Prof-i386-CD4.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.suse.com/9.3/iso/SUSE-9.3-Prof-i386-CD5.iso

cd /srv/isos/ubuntu/
mkdir 6.06-live
mkdir 6.06-live/CD
cd 6.06-live/CD
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ubuntu/releases/dapper/ubuntu-6.06-beta2-live-i386.iso

cd /srv/isos/ubuntu/
mkdir 6.06-install
mkdir 6.06-install/CD
cd 6.06-install/CD
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ubuntu/releases/dapper/ubuntu-6.06-beta2-install-i386.iso

cd /srv/isos/freebsd/
mkdir 6.1
mkdir 6.1/CD
cd 6.1/CD
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.freebsd.org/FreeBSD/releases/i386/ISO-IMAGES/6.1/6.1-RC2-i386-disc1.iso
wget -c 
$PROTOCOL://$FQDN/$FOLDER/ftp.freebsd.org/FreeBSD/releases/i386/ISO-IMAGES/6.1/6.1-RC2-i386-disc2.iso

cd /srv/isos/gentoo/
mkdir 2005.1
mkdir 2005.1/CD
cd 2005.1/CD
wget -c 
$PROTOCOL://$FQDN/$FOLDER/gentoo.org/releases/x86/2005.1-r1/installcd/install-x86-universal-2005.1-r1.iso

cd /srv/isos/impi
mkdir 601
mkdir 601/CD
cd 601/CD
wget -c $PROTOCOL://$FQDN/$FOLDER/impilinux/impilinux_601_EC.iso

cd /srv/isos/opencd
mkdir 3.1
mkdir 3.1/CD
cd 3.1/CD
wget -c $PROTOCOL://$FQDN/$FOLDER/OpenCD/releases/3.1/TheOpenCD-3.1.iso

cd /srv/isos/knoppix
mkdir 4.0.2
mkdir 4.0.2/CD
cd 4.0.2/CD
wget -c $PROTOCOL://$FQDN/$FOLDER/knoppix/KNOPPIX_V4.0.2CD-2005-09-23-EN.iso

cd /srv/isos/clusterknoppix/
mkdir 3.6
mkdir 3.6/CD
cd 3.6/CD
wget -c 
ftp://ftp.kulnet.kuleuven.ac.be/pub/mirror/clusterknoppix/clusterKNOPPIX_V3.6-2004-08-16-EN-cl1.iso

cd /srv/isos/edubuntu/
mkdir 6.0.6
mkdir 6.0.6/CD
cd 6.0.6/CD
wget -c 
http://releases.ubuntu.com/edubuntu/6.06/edubuntu-6.06-beta2-live-i386.iso

cd /srv/isos/firemonger/
mkdir 1.5.0.2
mkdir 1.5.0.2/CD
cd 1.5.0.2/CD
wget -c 
http://switch.dl.sourceforge.net/sourceforge/firemonger/firemonger_1.5.0.2_en.iso


cd /srv/isos/gutenberg/
mkdir 2003-08
mkdir 2003-08/CD
cd 2003-08/CD
wget -c 
ftp://ibiblio.org/pub/docs/books/gutenberg/1/1/2/2/11220/PG2003-08.ISO

cd /srv/isos/kubuntu
cd 5.10-Install-Kubuntu/CD
wget -c 
http://ubuntu.hands.com/releases/kubuntu/5.10/kubuntu-5.10-install-i386.iso

cd /srv/isos/openlab/
cd 4/CD
wget -c ftp://ftp.polytechnic.edu.na/pub/OpenLab/iso/openlab-live-4.0.0.iso

cd /srv/isos/whitebox/
mkdir manifest
mkdir manifest/CD
cd manifest/CD
wget -c 
ftp://ftp.belnet.be/packages/whiteboxlinux/4/en/iso/i386/manifestdestiny-binary-i386-1.iso
 
