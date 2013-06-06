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

print $q->start_html(-title=>"Check Config", 
				-encoding=>"UTF-8",
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::CGIURL."/admin.pl"},
               $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));

################################################################################
# Display the screen
################################################################################
print $q->start_div({-id=>'admin'});
print $q->h1(gettext("Check Toaster Configuration"));
print $q->h2(gettext("CDRW hdparm"));

foreach $burner (keys %Devices) {
   print $q->h3(sprintf(gettext("Settings for %s"),$burner));
   $device = $Devices{$burner}; # gives /dev/hdn path value
   print $q->pre($q->h4(sprintf(gettext("Device %s"),$device)), `/sbin/hdparm $device`);
}
print $q->end_div;
print $q->end_html;
exit;
################################################################################
