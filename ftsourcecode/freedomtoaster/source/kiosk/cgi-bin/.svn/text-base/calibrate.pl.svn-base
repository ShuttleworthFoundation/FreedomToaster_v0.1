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
print $q->start_html(-title=>gettext("Calibrate Burners"), 
				-encoding=>"UTF-8",
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::CGIURL."/admin.pl"},
               $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));

if ($task eq 'calibrate') {
   $cache->set('burnercount', -1);
   push @burners, sort keys %main::Devices;
   $cache->set('burners', \@burners);
   foreach $burner (@burners) {
      `sudo cdrecord dev=$main::Devices{$burner} -load`;
   }
} 
my $count   = $cache->get('burnercount');
$count++;
$cache->set('burnercount', $count);
@burners = @{$cache->get('burners')};
if ($count > 0) { # we've been through at least one test
   `sudo cdrecord dev=$main::Devices{$burners[$count-1]} -load`;
   %capabilities = %{$cache->get('burnercapabilities')} if ($count>1);
   $capabilities{$burners[$count-1]}{'Type'} = $q->param('DeviceType');
   $capabilities{$burners[$count-1]}{'Position'} = $q->param('position');
   $cache->set('burnercapabilities', \%capabilities);
}
if ($count > $#burners) { #finished calibrating...
   writeConfig();
exit;
} 
   
   


################################################################################
# Calibrate the burners with their capabilities
################################################################################
print $q->start_div({-id=>'admin'});
print $q->h1(gettext("Calibrate the Burners"));

my $burner = $burners[$count];
print $q->p(gettext("Please choose the right values for the burner that is being opened now"));
print $q->startform(-action=>$main::CGIURL.'/calibrate.pl');
my $result = `sudo cdrecord dev=$main::Devices{$burner} -eject`;
if ($result=~m/Device seems to be: .*?(CD|DVD).*?RW/) {
   $DeviceType = $1;
   print $q->p(gettext("Device seems to be a "), $q->popup_menu(-name=>'DeviceType',-values=>['CD','DVD'],-default=>$DeviceType), gettext(" writer"), br(),br(),br());
   my $countval = $count + 1;
   print $q->p(gettext("In position: "), $q->popup_menu(-name=>'position', -values=>[1..$#burners+1],-default=>$countval), br(),br(),br());
}
print $q->submit(gettext('Next >'));
print $q->endform;

print $q->end_div;
print $q->end_html;
exit;

sub writeConfig() {
################################################################################
print $q->start_div({-id=>'content'});
print $q->h1(gettext("Calibration Results"));
my $ConfigFile = $main::CGIDir.'/config.pl';
foreach $burner (sort @burners) {
   if ($burner =~ m/([0-9]+)$/) {
      $count = $1;
   }
   my $Position = $capabilities{$burner}{'Position'} - 1;
   my $ActualLabel = $burner;
   my $PositionLabel = 'cdrw'.$Position;
   print $q->p($burner, gettext(" is labeled "), $capabilities{$burner}{'Position'}, gettext(" and is a "), $capabilities{$burner}{'Type'}, "-RW");
   if ($count ne $Position) {
      `perl -pi -e 's/$PositionLabel/PlaceHolder/i' $ConfigFile`; 
      `perl -pi -e 's/$ActualLabel/$PositionLabel/i' $ConfigFile`; 
      `perl -pi -e 's/PlaceHolder/$ActualLabel/i' $ConfigFile`; 
      print $q->p(sprintf(gettext("Swapping devices around in %s..."),$ConfigFile));
      my $PositionCapability = $capabilities{$ActualLabel}{'Type'};
      $capabilities{$ActualLabel}{'Type'} = $capabilities{$PositionLabel}{'Type'};
      $capabilities{$PositionLabel}{'Type'} = $PositionCapability;
      my $ActualPosition = $capabilities{$ActualLabel}{'Position'};
      $capabilities{$ActualLabel}{'Position'} = $capabilities{$PositionLabel}{'Position'};
      $capabilities{$PositionLabel}{'Position'} = $ActualPosition;
   }
}
$cache->set('burnercapabilities', \%capabilities);
### Add this to the config file...
   my $CapabilityString = '%main::Capabilities = (';
   foreach $burner (sort keys %capabilities) {
      $CapabilityString .= "'$burner' => '" . $capabilities{$burner}{'Type'} . "', ";
   }
   $CapabilityString =~ s/, $/ );/;
   if (!`grep 'main::Capabilities' $ConfigFile`) {
      `echo "$CapabilityString" >> $ConfigFile`;
   } else {
      `perl -pi -e 's#%main::Capabilities.*$#\Q$CapabilityString\E#' $ConfigFile`;
   }

### Other things to add are:
# $main::GrowISOfsParms = '-dvd-compat -use-the-force-luke=tty,dao -J -R -dry-run' 

print $q->p(gettext("New config is: "), pre(`grep -i cdrw $ConfigFile`));
print $q->startform(-action=>$main::CGIURL.'/admin.pl');
print $q->submit(-value=>gettext('Done'));
print $q->endform;
print $q->end_div;
print $q->end_html;
}
