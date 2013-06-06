#!/usr/bin/perl
###!/usr/bin/perl -w
#use strict;
use CGI qw(:all);
require ("config.pl");
use Cache::FileCache;
use POSIX;
use Locale::gettext;

my $q = new CGI;
my $task = $q->param('task');
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);

my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";

my $admin = $cache->get('admin');

if (!$admin) {
   require("admin.pl");
   exit;
} 
   

print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
print $q->start_html(-title=>gettext("Install Upgrade"), 
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::CGIURL."/admin.pl"},
               $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));

################################################################################
# Display upgrade options and results.  The steps are simple:
# 1) Backup by tarring the current main directory to /home/kiosk
# 2) Mount CD containing the update...
# 3) Find tarball called toaster-n.m.tar.gz, where n.m is bigger than current 
#    version in the config file
# 4) Crack the tarball and hope for the best!
################################################################################
print $q->start_div({-id=>'admin'});
print $q->h1(gettext("Upgrade Kiosk Software"));
print $q->p(gettext("To do this you need a CD with the upgrade on it.  You will be prompted to put it into a CDROM drive, and will need to confirm whether you want to upgrade to the version on the CD."));
print $q->p(strong(gettext("Note:")), sprintf(gettext("the system will only upgrade if the file on the CD has a name of 'toaster-n.m.tar.gz' where n.m is the version number and it is bigger than the setting of \%s in %s/config.pl"),$main::Version,$main::CGIDir));
print $q->p(strong(gettext("Note:")), gettext("the system <b>does a backup</b> by tarballing the current system to /home/kiosk.  Make sure that this succeeds - your most likely source of trouble will be permissions to that folder (run <em>#sudo chmod -R a+w /home/kiosk</em> in a terminal)."));



print $q->h2(gettext("Backup Existing Code"));
my $backuptarballname = "/home/kiosk/codebackup-$main::Version.tar.gz";
my $increment = 0;
while ( -e $backuptarballname ) { # increment the name until it is unique
   $backuptarballname = "/home/kiosk/codebackup-$main::Version.$increment.tar.gz";
   $increment++;
}
if (system("cd $main::BaseDir;tar -czf $backuptarballname ./") eq 0) {
   print $q->p(gettext("Backup successfully completed to "), strong($backuptarballname));
} else {
   print $q->p(strong(gettext("Backup Failed. Aborting. You must fix this problem before you can upgrade your software")));
   exit;
}
 
my $device = findUnmountedCD();
if ($device !~ /dev/) {
   print $q->p(gettext("No unmounted CD drives found. Aborting until you fix it."));
   exit;
}
print $q->p(gettext("Insert the upgrade CD in the open CDROM drive (you have 20 seconds)"));
system('cdrecord dev='.$device.' -eject 2>/dev/null 1>&2');
sleep 20;
if (system('mount '.$device.' 2>/dev/null 1>&2') ne 0) {
   print $q->p(sprintf(gettext("Unable to mount %s. Aborting"),$device));
   exit;
}

my $cdpath = getMountPath($device);
my $upgradeFile;
my $newVersion;
opendir(DIR, $cdpath) or die "opening directory $cdpath : $!";
for (readdir(DIR)) {
   next if (/^\./);
   my $currentFile = "$cdpath/$_";
   if (/toaster-(\d+?)\.(\d+?)\.tar\.gz/) {
      my $major = $1;
      my $minor = $2;
      print $q->p(sprintf(gettext("Found : %s with version %d.%d"),$currentFile,$major,$minor));
      if (($main::Version < "$major.$minor") and ($newVersion < "$major.$minor")) {
         print $q->p(sprintf(gettext("This is newer than our current version of %s"),$main::Version), strong(gettext(" Installing it...")));
         $upgradeFile = $currentFile;
         $newVersion = "$major.$minor";
      }
   }
}
close(DIR);
if ($upgradeFile ne '') {
   my $tarballcrack = `cd $main::BaseDir;tar -zxf $upgradeFile`;
   chomp($tarballcrack);
   print $q->p(gettext("Upgrade installed: ").$tarballcrack);
# This is where we would update the config file
   if (system("perl -pi -e \"s/main::Version = '[^']*';/main::Version = '$newVersion';/\" $main::CGIDir/config.pl") ne 0) {
      print $q->p(sprintf(gettext("Unable to set new version to %s in %s/config.pl"),$newVersion,$main::CGIDir));
   }

} else {
   print $q->p(gettext("No suitable files found on the CD. Aborting."));
}
system "eject $device ";#.'2>/dev/null 1>&2';
system "umount $device".' 2>/dev/null 1>&2';
exit;


print $q->end_div;
print $q->end_html;
exit;

