#!/usr/bin/perl -w
use strict;
################################################################################
# Machine layout-specific parameters
# (NO slashes at the end of directory paths please!)
################################################################################
$main::BaseURL = '..';
$main::HTMLURL = $main::BaseURL.'/locale'; # language sub-dir is appended at runtime
$main::ImageURL = $main::BaseURL.'/images';
$main::CSSURL = $main::BaseURL.'/css';
$main::CGIURL = $main::BaseURL.'/cgi-bin';

$main::BaseDir = '/srv/www/kiosk';
$main::HTMLDir = $main::BaseDir.'/locale';
$main::ImageDir = $main::BaseDir.'/images';
$main::CSSDir = $main::BaseDir.'/css';
$main::CGIDir = $main::BaseDir.'/cgi-bin';

$main::IsoDir = '/srv/isos';

$main::debug = 1; # Prints info to /tmp/toaster when on
################################################################################
# Map CD and/or DVD devices to IDE devices in /dev
# Remarks: Although this mapping can be done in /etc/cdrecord/cdrecord, writing
#          DVDs requires growisofs which does not use those defaults.  So for
#          consistency, and to move the Freedom Toaster configuration all into
#          this one file, we do the mappings here.
################################################################################
#$main::CDRecordParms = '-dummy'; # Set to blank for live writing
$main::CDRecordParms = ''; # Set to '-dummy' for testing

%main::Devices = ('cdrw0' => '/dev/hda',
                  'cdrw1' => '/dev/hdb',
                  'cdrw2' => '/dev/hdc',
                  'cdrw3' => '/dev/hdd',
                  'cdrw4' => '/dev/hde');

require('common.pl');
$main::LogFile = '/home/kiosk/toasting.log';
$main::Version = '3.00';

$main::AdminPass = 'M0xKTEL9t51+vD5ztRfm+A';
$main::ToasterName = 'freedom1';
%main::Capabilities = ('cdrw0' => 'DVD', 'cdrw1' => 'DVD', 'cdrw2' => 'DVD', 'cdrw3' => 'DVD', 'cdrw4' => 'DVD');
