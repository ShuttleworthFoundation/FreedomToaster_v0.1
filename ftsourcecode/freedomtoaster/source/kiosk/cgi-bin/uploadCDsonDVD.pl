#!/usr/bin/perl
################################################################################
#                               uploadCDsonDVD.pl 
#                               ===============
# Purpose : Admin function to read the cdrw[0-9].xml file on a DVD and use it
#           to copy the isos on the DVD to the right place on the toaster.
# Input   : The content on CD or DVD that is inserted into a CDROM drive
#           cdrw[0-9].xml - tells us where to put the isos on the disk
# Output  : The isos mentioned in the xml file are copied to $main::IsoDir
# License : GPL
# Author  : Charles Oertel (2006-06-12)
################################################################################
use CGI qw(:all);
require ("config.pl");
use Cache::FileCache;
use POSIX;
use Locale::gettext;
use XML::Simple;

my $q = new CGI;
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);
my $ImageURL = "../locale/".substr($lang,0,2)."/images";

my $task = $q->param('task');
my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";

my $admin = $cache->get('admin');

if (!$admin) {
   require("admin.pl");
   exit;
} 
################################################################################
# Control Variables: insertCD  - open drive and prompt for user to insert CD
#                    loadFiles - read in the isos on the disk
#                    Prompt    - more or finish?
################################################################################
#
$device = $cache->get('CDonDVDDevice');
$step = $cache->get('CDonDVDStep');
if ($q->param('next')) {
   if ($step eq 'insertCD') {
      $task = 'loadFiles';
   } elsif ($step eq 'loadFiles') {
      $task = 'home';
   }
} elsif ($q->param('back')) {
   if ($step eq 'loadFiles') {
      system("umount $device") if ($device ne '');
      $task = 'insertCD';
   }
}

if ($step eq '') {
   system("umount $device") if ($device ne '');
   $task = 'insertCD';
}


print $q->header;

print $q->start_html(-title=>gettext("Upload Content"), 
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL."/images/H_button.gif"})));
print $q->div({-id=>'MoreInfo'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/help/uploadCDsonDVD.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/K_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::CGIURL."/admin.pl?task=uploadCDsonDVD&back=1"},
               $q->img({-name=>'back', -src=>$main::CSSURL."/images/L_button.gif"})));

################################################################################
# Display the screen
################################################################################
print $q->start_div({-id=>'admin'});
print $q->h1(gettext("Upload Freedom Toaster Content"));

if ($task eq 'insertCD') {
   insertCD();
} elsif ($task eq 'loadFiles') {
   loadFiles();
}

print $q->end_div;
print $q->end_html;
exit;
################################################################################

sub insertCD() {
   my $device = findUnmountedCD();
   if ($device !~ /dev/) {
      print $q->p(gettext("No unmounted CD drives found. Wait for burning to finish or remove CDs currently
                  busy in the drives. Aborting until you fix it."));
      exit;
   }
   system("cdrecord dev=$device -eject 2>/dev/null 1>&2");
   print $q->startform(-action=>$CGIURL.'/admin.pl');
   print $q->hidden(-name=>'task', -value=>'uploadCDsonDVD');
   print $q->h3(gettext("Insert your CD/DVD in the open CDROM drive then click 'Next'"));
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png', -align=>'center');
   print $q->endform();
   $cache->set('CDonDVDDevice', $device);
   $cache->set('CDonDVDStep', 'insertCD');
}

sub loadFiles() {
   my $uploadFile = '';
   $cache->set('CDonDVDStep', 'uploadFiles');
   print $q->h2(gettext("Uploading Files from the Disk"));

   my $mounted = `mount | grep -c $device`;
   if ($mounted==0) {
      if (system('mount '.$device.' 2>/dev/null 1>&2') ne 0) {
         print $q->p(sprintf(gettext("Unable to mount %s. Aborting"),$device));
         exit;
      } 
   }
   my $xmlFileName;
   $cdpath = getMountPath($device);
      opendir(DIR, $cdpath) or die "opening directory $cdpath : $!";
	for (readdir(DIR)) {
		next if (/^\./);
		next if (/.iso$/);
		if (/cdrw[0-9].xml/) {
			$xmlFileName = "$_";
		}
	}
	close(DIR);
	my $xml = XMLin($cdpath.'/'.$xmlFileName);
        my @distros = @{$xml->{distros}};
        print $q->p(sprintf(gettext("Found %s with %d distros"), $xmlFileName, scalar(@distros)));
        foreach $distro (@distros) {
           print $q->p(sprintf(gettext("Copying %s to %s"), $distro->{file}, $main::IsoDir.'/'.$distro->{distro}.'/'.$distro->{version}.'/'.$distro->{medium}.'/'));
			  if (! -e $main::IsoDir.'/'.$distro->{distro}.'/'.$distro->{version}.'/'.$distro->{medium}.'/') {
				  system("mkdir -p $main::IsoDir/".$distro->{distro}.'/'.$distro->{version}.'/'.$distro->{medium}); 
			  }
           system("cp $cdpath/".$distro->{file}." $main::IsoDir/".$distro->{distro}.'/'.$distro->{version}.'/'.$distro->{medium}.'/');
           system("chmod +R u+w $main::IsoDir/".$distro->{distro});
	}

   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png', -align=>'center');
   print $q->endform();
   exit;
}

