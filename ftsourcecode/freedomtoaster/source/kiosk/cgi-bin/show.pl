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

print $q->start_html(-title=>gettext("Show Queues"), 
				-encoding=>"UTF-8",
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::CGIURL."/admin.pl"},
               $q->img({-name=>'back', -src=>$main::ImageURL.'/L_button.gif'})));

################################################################################
# Display the screen
################################################################################
print $q->start_div({-id=>'content'});
print $q->h1(gettext("Show Queue Status"));
 
   my @distroVersions = @{$cache->get('distroVersion')};
   my @distroDisks = @{$cache->get('distroDisks')};
   print $q->h2(gettext("Shopping Cart").sprintf(ngettext(" (%d item)"," (%d items)",int(@distroDisks)), int(@distroDisks)));
   foreach $Disk (@distroDisks) {
      my @disk = @{$Disk};
      foreach $iso (@disk) {
         print $q->ol($q->li($iso));
      }
   }

   my @DVDQueue = @{$cache->get('DVDQueue')};
   my @CDQueue = @{$cache->get('CDQueue')};
   
################################################################################
# Ok, let's see what we have here:  Print the DVDQueue and the CDQueue
# (This section also shows you how to dereference the queues...

   print $q->h2(sprintf(gettext("DVD Queue").ngettext(" (%d item)"," (%d items)",int(@DVDQueue)),int(@DVDQueue)));
   foreach $DVDHash (@DVDQueue) {
      my %DVD = %{$DVDHash};
      my %DiskData = %{$DVD{'DVD'}};
      my @DiskArray = @{$DVD{'CDs'}};
      print $q->p(sprintf(gettext("Volume %s:"), $DVD{'Volume'}));

      if (@DiskArray) {
         foreach $Disk (@DiskArray) {
            my %DiskData = %{$Disk};
            print $q->ol(
                  $q->li($DiskData{'distro'}, " ", 
                         $DiskData{'version'}, " ", 
                         $DiskData{'medium'}, " ", 
                         $DiskData{'diskno'}, gettext(" of "), 
                         $DiskData{'total'}));
         }
      } else {
         print $q->ul(
                  $q->li($DiskData{'distro'}, " ", 
                         $DiskData{'version'}, " ", 
                         $DiskData{'medium'}, " ", 
                         $DiskData{'diskno'}, gettext(" of "), 
                         $DiskData{'total'}));
      }
   }
   print $q->h2(sprintf(gettext("CD Queue").ngettext(" (%d item)"," (%d items)",int(@CDQueue)),int(@CDQueue)));
   foreach $CDHash (@CDQueue) {
      my %CD = %{$CDHash};
      print $q->p(sprintf(gettext("Volume %s:"), $CD{'Volume'}));
      if (defined($CD{'CD'})) {
         my %DiskData = %{$CD{'CD'}};
         print $q->ul(
                  $q->li($DiskData{'distro'}, " ", 
                     $DiskData{'version'}, " ", 
                     $DiskData{'medium'}, " ", 
                     $DiskData{'diskno'}, gettext(" of "), 
                     $DiskData{'total'}));
      } elsif (defined($CD{'Path'})) {
         print $q->ul(
               $q->li(gettext("Iso Path: "), $CD{'Path'}));
      }
   }
#
# End of Debug Printing to examine queues (and show you how to access the data)
################################################################################
   
print $q->end_div;
print $q->end_html;
exit;
################################################################################
