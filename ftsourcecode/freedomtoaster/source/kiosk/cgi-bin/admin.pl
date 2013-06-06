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

my $kioskScriptPath = "/home/kiosk/bin/";
my $admin = $cache->get('admin');
if ($task eq 'logout') {
   $cache->set('admin','');
} elsif ($task eq 'calibrate') {
   require("calibrate.pl");
   exit;
} elsif ($task eq 'uploadCCFile') {
   if ($q->param('start')) { #clear cache settings
         $cache->remove('CCStep');
         $cache->remove('CCDevice');
         $cache->remove('CCMountPath');
         $cache->remove('CCUploadFile');
         $cache->remove('CCFileType');
         $cache->remove('CCAuthorName');
         $cache->remove('CCCommercial');
         $cache->remove('CCDerivatives');
         $cache->remove('CCSelectedTags');
   }
   require("uploadCCFile.pl");
   exit;
} elsif ($task eq 'burnCCFiles') {
   if ($q->param('start')) { #clear cache settings
         $cache->remove('CCStep');
         $cache->remove('CCFileTypes');
         $cache->remove('CCIgnoreFileTypes');
         $cache->remove('CCAuthors');
         $cache->remove('CCIgnoreAuthors');
         $cache->remove('CCLicenses');
         $cache->remove('CCIgnoreLicenses');
         $cache->remove('CCTags');
         $cache->remove('CCAllTags');
         $cache->remove('CCFiles');
         $cache->remove('CCBurnMedium');
         $cache->remove('CCValidFilePaths');
   }
   require("burnCCFiles.pl");
   exit;
} elsif ($task eq 'uploadCDsonDVD') {
   if ($q->param('start')) { #clear cache settings
         $cache->remove('CDonDVDStep');
         $cache->remove('CDonDVDDevice');
   }
   require("uploadCDsonDVD.pl");
   exit;
} elsif ($task eq 'show') {
   require("show.pl");
   exit;
} elsif ($task eq 'eject') {
   unmountCDs();
} elsif ($task eq 'unkiosk') {
   if (-e $kioskScriptPath."unkiosk.sh") {
      system("sudo ".$kioskScriptPath."unkiosk.sh & 2>/dev/null 1>&2");
   }      
} elsif ($task eq 'kiosk') {
   if (-e $kioskScriptPath."kiosk.sh") {
      system("sudo ".$kioskScriptPath."kiosk.sh & 2>/dev/null 1>&2");
   }
} elsif ($task eq 'upgrade') {
   require("upgrade.pl");
   exit;
} elsif ($task eq 'clear') {
   $cache->clear();
   `for F in \$(ls /tmp/cdrw*); do rm -f \$F; done`;
}
if (!$admin) {
   require("login.pl");
   exit;
}

print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");

print $q->start_html(-title=>gettext("Administrator Menu"), 
				-encoding=>"UTF-8",
				-head=>meta({-http_equiv =>'refresh', -content => '5'}),
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL."/images/H_button.gif"})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'back', -src=>$main::CSSURL."/images/L_button.gif"})));

################################################################################
# Now we read in a list of items to present and put them in a grid with 
# pretty pictures etc gleaned from their directory in the /iso/ location
################################################################################
print $q->start_div({-id=>'admin'});
print $q->h1(sprintf(gettext("Freedom Toaster Version %s : Admin"),$main::Version));

showMenu();
showBurnerQueues();
showBurners();
print $q->end_div;
print $q->end_html;

sub showBurners() {
   my @Burners = sort keys %main::Devices;
    
   print "<table style=\"width:80%;font-size:small;color:black;text-align:center;margin-bottom:2em;background:#eee;\"><tr>\n";

   foreach $dev (@Burners) {
      my $CDRW;
      if ($dev=~m/([0-9]+)$/) {
         my $Num = $1 + 1;
         $CDRW = "$main::Capabilities{$dev}-RW $Num";
      }
      print "<td width=\"33%\" style=\"width:33%;border:1px solid gray;\"><strong>$CDRW</strong><br />\n";
      # Get Device Status
      my @keys = sort $cache->get_keys();
      foreach $key (@keys) {
         if ($key =~ m/$dev/i) { # something to do with our device...
            my $label = $key;
            if ($label=~m/queue.$dev/i) {
               my %item = %{$cache->get($key)}; 
               print gettext("Queued = '"), $item{'Volume'}, "'<br />\n";
            } else {
               $label =~ s/$dev//i;
               print "$label = '", $cache->get($key), "'<br />\n";
            }
         }
      }
      print "</td>\n";
   }
   print "</tr></table>\n";
}
sub showMenu() {
#   print $q->a({href=>$main::CGIURL.'/admin.pl?task=checkconfig', class=>'button'}, gettext('Check Configuration'));

   print $q->a({href=>$main::CGIURL.'/admin.pl?task=calibrate', class=>'button'}, gettext('Calibrate CDs'));
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=eject', class=>'button'}, gettext('Eject Drives'));
   print br();
   print br();
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=uploadCCFile&amp;start=1', class=>'button'}, gettext('Upload CC Content File'));
   print br();
   print br();
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=uploadCDsonDVD&amp;start=1', class=>'button'}, gettext('Upload ISOs'));
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=upgrade', class=>'button'}, gettext('Software Upgrade'));
   print br();
   print br();
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=unkiosk', class=>'button'}, gettext('Un-Kiosk'))    if (-e $kioskScriptPath."unkiosk.sh");
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=kiosk', class=>'button'}, gettext('Kiosk'))    if (-e $kioskScriptPath."kiosk.sh");
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=clear', class=>'button'}, gettext('Clear Caches'));
   print $q->a({href=>$main::CGIURL.'/admin.pl?task=logout', class=>'button'}, gettext('Log Out'));
}
