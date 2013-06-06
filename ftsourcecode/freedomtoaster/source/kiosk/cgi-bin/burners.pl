#!/usr/bin/perl
###!/usr/bin/perl -w 
use CGI qw(:all);
use Cache::FileCache;
require("config.pl");
use POSIX;
use Locale::gettext;

open(OUTFILE, ">>/tmp/Toaster") or die "can't open file for writing: $!";

$|=1;
my $q = new CGI;
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);
my $ImageURL = "../locale/".substr($lang,0,2)."/images";

my $device = getDevice();
#print OUTFILE "Device=$device:\n";
#print OUTFILE "   Load=".$q->param('Load')."\n";
#print OUTFILE "   Cancel=".$q->param('Cancel')."\n";
#print OUTFILE "   Retry=".$q->param('Retry')."\n";
#print OUTFILE "   Done=".$q->param('Done')."\n";
#print OUTFILE "   Dump=".$q->Dump."\n";
my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Can't create file cache in newKiosk namespace";

if ($device) { 
   if ($q->param('Toast.x')) {
      my $child;
      $cache->set("prompting.$device",0);
      if (($child = fork()) > 0) {
            # parent code
      } else {
         # child code
         close(STDIN);
         close(STDERR);
         close(STDOUT);
         my $toasting = "toasting.$device";
         $cache->set("$toasting",1);
         %item = %{$cache->get("queue.$device")};
         my $IsoArray = getIsos($device); # This also sets 'medium' for DVD of CDs..!
         my $result = burnMedium($device, $IsoArray, $cache->get("medium.$device"), $item{'Volume'});
         $cache->set("$toasting",0);
         $cache->set("status.$device",$result);
         alarm 1;
         exit;
      }
   } elsif ($q->param('Blank.x')) {
      my $child;
      $cache->set("prompting.$device",0);
      if (($child = fork()) > 0) {
            # parent code
      } else {
         # child code
         close(STDIN);
         close(STDERR);
         close(STDOUT);
         $cache->set("toasting.$device",1);
         $cache->set("blanking.$device",1);
         my $result = blankMedium($device, $cache->get("medium.$device"));
         $cache->set("blanking.$device",0);
         $cache->set("toasting.$device",0);
         $cache->set("status.$device",$result);
         `rm /tmp/$device 2>/dev/null`;
         alarm 1;
         exit;
      }
   } elsif ($q->param('Cancel.x')) {
      # die "Cancel";
      $cache->remove("queue.$device");
      $cache->set("prompting.$device",0);
      $cache->set("status.$device",'Ready');
      $cache->set("percentage.$device",0);
      `rm /tmp/$device 2>/dev/null`;
   } elsif ($q->param('Retry.x')) {
      #die "Retry";
      $cache->set("prompting.$device",0);
      $cache->set("status.$device",'Ready');
      $cache->set("percentage.$device",0);
      `rm /tmp/$device 2>/dev/null`;
   } elsif ($q->param('Done.x')) {
      #die "Done";
      $cache->remove("queue.$device");
      $cache->set("prompting.$device",0);
      $cache->set("status.$device",'Ready');
      $cache->set("percentage.$device",0);
      `rm /tmp/$device 2>/dev/null`;
   }
}



################################################################################
### cjpo: Now read and display status of the burn for each CD

### todo ### if burn=cdrwx then load tray and start burning, set toasting to 1
#   burnMedium($resource, $distroIsos, $medium, $volume);
# refresh to this page...
   
my @BurnStatus;
my @Burners = sort keys %main::Devices;

foreach $dev (@Burners) {
   my $CDRW;
   if ($dev=~m/([0-9]+)$/) {
      my $Num = $1 + 1;
      $CDRW = "$main::Capabilities{$dev}-RW $Num";
   }
   
   # Get Device Status
   my $toasting = $cache->get("toasting.$dev");
   my $status = $cache->get("status.$dev");
   my $prompting = $cache->get("prompting.$dev");

   $status = 'Ready' if !$status or ($status eq 'toasting');
   my $queued = $cache->get("queue.$dev");
   # If device idle/finished/waiting, fetch files to burn
   if (!$toasting and ($status eq 'Ready') and (!$queued)) {
      # fetch files to burn:
      # if capability=DVD then look on DVD queue first
      if ($main::Capabilities{$dev} eq 'DVD') { # check the DVD queue
         my @DVDQueue = @{$cache->get('DVDQueue')};
         if (@DVDQueue) {
            $queued = shift @DVDQueue;
            $cache->remove('DVDQueue');
            $cache->set('DVDQueue', \@DVDQueue);
            $cache->set("queue.$dev", $queued);
            $cache->set("medium.$dev", 'DVD');
         }
      } 
      # if no DVD queued, or anyway, look on CD queue 
      if (!$queued) { # no DVD queued, check for CDs...
         my @CDQueue = @{$cache->get('CDQueue')};
         if (@CDQueue) {
            $queued = shift @CDQueue;
            $cache->remove('CDQueue');
            $cache->set('CDQueue', \@CDQueue);
            $cache->set("queue.$dev", $queued);
            $cache->set("medium.$dev", 'CD');
         }
      }
   }
   # At this stage we don't actually know what is going on (device status-wise ;-)
#   print OUTFILE interpretStatus($dev) if ($dev eq "cdrw1");
#   getStatus($dev) if ($dev eq "cdrw1");
   if (!$toasting and $queued) { 
      if ($status eq 'Ready') { # open drive and prompt for DVD/CD
         `sudo cdrecord dev=$main::Devices{$dev} -eject` if (!$prompting);
         push @BurnStatus, $q->h2($CDRW).promptForDisk($dev,$status);
      } elsif ($status =~ m/blanked/i) { # open drive and prompt for DVD/CD
         push @BurnStatus, $q->h2($CDRW).promptForDisk($dev,$status);
      } else { # not ready => been burning, so prompt to remove DVD/CD
         push @BurnStatus, $q->h2($CDRW).promptToRemoveDisk($dev,$status);
      }
      $cache->set("prompting.$dev", 1);
    } else {
       if (!$toasting and !$queued and ($status ne 'Ready')) {
          $cache->set("status.$dev", 'Ready');
       }
      push @BurnStatus, $q->h2($CDRW).interpretStatus($dev);
    }

}

### cjpo: Now print the page

print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
print $q->start_html(-title => "Slideshow while $medium$plural toasting",
		-encoding=>"UTF-8",
		-head=>meta({-http_equiv =>'refresh', -content => '10'}),
		-style=>{'src' => [ $main::CSSURL."/burners.css", $main::CSSURL."/tooltip.css" ] },
		-background =>$main::CSSURL."/images/burnersBG.png");
print $q->start_div({-id=>'content'});
print $q->start_div({-id=>'topStatusBox'});
foreach $status (@BurnStatus) {
	print $q->div({-class=>'CDRWStatus'}, $status);
}
#foreach $disk (@queue) {
#   print $q->p($disk);
#   print $q->p('hello');
#}
print $q->a({-href=>$main::CGIURL."/showQueue.pl", -target=>'contentarea'},
         $q->img({-src=>$ImageURL."/show_toast_list.png", -border=>'0', -title=>gettext('Show the queues of selected CDs and DVDs waiting to toast'), -align=>'center'}));
#showQueues();
print $q->end_div;
print $q->end_div;
print $q->end_html;

exit;


sub getStatus {
################################################################################
# Purpose: Read and interpret CD Burner status from temp pipe output
# Input  : cdrw = the name of the pipe to read in /tmp
# Output : HTML that will show the burner status
# Remarks: The HTML will vary until a suitable format is found
################################################################################
   my ($cdrw) = (@_);
   my $line = gettext("Ready");

   if (-e "/tmp/$cdrw") {
      $line = `tail -1 /tmp/$cdrw`; 
      open CDRW, "/tmp/$cdrw" or die "Cannot open /tmp/$cdrw for reading: $!";
      my $content = join(' ', <CDRW>);
      close CDRW;

      if ($content =~ /Is erasable/sig) {
         $cache->set("erasable.$cdrw",1);
      } else {
         $cache->set("erasable.$cdrw",0);
      }

      $cache->set("status.$cdrw",'busy');
      if ($cache->get("blanking.$device")) {
         if ($content=~m/Cannot blank disk/sig) {
            $cache->set("status.$cdrw",'Blanking failed');
         } else {
            $cache->set("status.$cdrw",'blanking');
         }
      }

      #:-( /dev/hdc: media is not recognized as recordable DVD: 0
      if ( $content =~ /:-\(/si ) {
         my $status = "failed";
         if ( $content =~ m/media is not recognized as recordable ([^:]*)/si ) {
            $status = "no recordable $1";
         }
         $cache->set("status.$cdrw",$status);
      }


      # Fixating...
      if ($content=~m/Fixating\.\.\./sig) {
         $cache->set("status.$cdrw",'fixating');
      }

      if (`grep -ic 'Total bytes read/written' /tmp/$cdrw` > 0) {
         $cache->set("status.$cdrw","finished");
      }
      if ($content=~m/.*extents written (\([^)]+\))/sig) {
         $cache->set("status.$cdrw","finished $1");
      }

      if (($content =~ m/checking recorded media/sig) or
          ($content =~ m/media cannot be written/sig) or
          ($content =~ m/already carries isofs/sig) or
          ($content =~ m/try to blank the media first/sig)) {
         $cache->set("status.$cdrw",'Disk not blank');
      }
   }
   # Now the progress lines are one long line with \r (carriage return) chars
   # to make the line overwrite itself and show a continuously updating line
   # without scrolling off the screen.  We must trash everything and show only 
   # the last line of it.
   $line =~ s/^.*\r//;
   return $line;
}

sub interpretStatus {
   my ($device) = @_;
#   my $toasting = $cache->get("toasting.$device");
   my $status = $cache->get("status.$device");
#   my $queued = $cache->get("queue.$device");
#   my $prompt = $cache->get("prompt.$device");

   my ($Speed, $Remaining);
   my $Light = '';
   my $Percentage = $cache->get("percentage.$device"); 
   my $PercentageStr = gettext("Empty");
   my $SpeedStr = '';
   my $deviceStatus = $cache->get("toasting.$device"); 
   my $StatusString = getStatus($device);
   if ($deviceStatus) {
      $Light = "<div id=\"BlinkingLight\"></div>";
      if ($Percentage) {
         $PercentageStr = gettext('Finishing');
      } elsif ($cache->get("blanking.$device")) {
         $PercentageStr = gettext('Blanking');
      } else {
         $PercentageStr = gettext('Toasting');
      }
   }

   if ($StatusString=~/[0-9]+\/[0-9]+\s+\(([^)]+)\)\s+\@([^,]+),\s+remaining\s+(.*)/) {
      $Percentage = $1;
      $Speed = $2;
      $Remaining = $3;
      if ($Percentage =~ m/([0-9]+)/) {
         $Percentage = $1;
      }
      $PercentageStr = $Percentage.'%' if $Percentage;
      $SpeedStr = sprintf(gettext("Speed: %s<br />"), $Speed);
   } elsif ($StatusString=~/([0-9]*)\s+of\s+([0-9]*)\s.*?\s([0-9.x]*)$/) {
      my ($done, $todo) = ($1, $2);
      $Speed = $3;
      $Percentage = sprintf("%4.0f", 100*$done/$todo) if ($todo>0);
      $PercentageStr = $Percentage.'%';
      $SpeedStr = sprintf(gettext("Speed: %s<br />"), $Speed);
   } elsif ($StatusString=~/([0-9.]*)\% done,/) {
#   38.80% done,
      $Percentage = $1;
      $PercentageStr = $Percentage.'%';
   }
   $cache->set("percentage.$device", $Percentage);
   if ($Percentage eq '')	{ $Percentage = 0; }
   $StatusString = "<div class=\"StatusMarker\" style=\"width:$Percentage"."px;\"></div><p class=\"Percentage\">$PercentageStr</p>$Light";
   return $StatusString.$q->p($SpeedStr.gettext("Status: ").$status); 
}

sub promptForDisk {
   my ($device, $status) = @_;
   my %Item = %{$cache->get("queue.$device")};
   my $output = $q->p(gettext("Load "), $cache->get("medium.$device"), gettext('<br />volume '), $Item{'Volume'});
   my %DiskData;
   if (defined($Item{'DVD'})) {
      %DiskData = %{$Item{'DVD'}};
   } elsif (defined($Item{'CDs'})) {
      my @DiskArray = @{$Item{'CDs'}};
      my %Volume = %{$DiskArray[0]};
      %DiskData = %{$Volume{'CD'}};
   } elsif (defined($Item{'CD'})) {
      %DiskData = %{$Item{'CD'}};
   }
   my $distro = $DiskData{'distro'};
   my $ImageFile = $main::ImageURL."/$distro"."B.png";
   $output .= "<img src=\"$ImageFile\" height=\"30\" align=\"center\" style=\"position:absolute;top:25px;left:40px\" />";
   $output .= '<table><tr><td>';
   $output .= $q->startform(-action=>$main::CGIURL.'/burners.pl');
   $output .= $q->hidden(-name=>$device, -value=>'1');
   $output .= $q->image_button(-name=>'Cancel', -title=>gettext("Don't toast this, cancel it"), -src=>$ImageURL."/skip.png");
   $output .= $q->image_button(-name=>'Toast', -title=>gettext("Burn to Disk"), -src=>$ImageURL."/toast.png");
   $output .= $q->endform;
   $output .= '</td></tr></table>';
   return $output;
}
sub promptToRemoveDisk {
   my ($device, $status) = @_;
   my %Item = %{$cache->get("queue.$device")};
   my $output = $q->p($cache->get("medium.$device"), gettext(' volume '), $Item{'Volume'}, br(), gettext("Status: ").$status);
   $output .= '<table><tr><td>';
   $output .= $q->startform(-action=>$main::CGIURL.'/burners.pl');
   $output .= $q->hidden(-name=>$device, -value=>'1');
   $output .= $q->image_button(-name=>'Retry', -title=>gettext("Try Again"), -src=>$ImageURL."/retry.png") if $status ne 'finished';

   if ($status ne 'finished' and $cache->get("erasable.$device")) {
      $output .= $q->image_button(-name=>'Blank', -title=>gettext("Blank this disk"), -src=>$ImageURL."/blank.png");
   } else {
      $output .= $q->image_button(-name=>'Done', -title=>gettext("Finished - disk removed"), -src=>$ImageURL."/done.png");
   }
   $output .= $q->endform;
   $output .= '</td></tr></table>';
   return $output;
}
sub getDevice {
   for (my $i=-1; $i<5; $i++) {
#      print OUTFILE "q->param(\"cdrw$i\")=".$q->param("cdrw$i")."\n";
      if  ($q->param("cdrw$i")) {
#         print OUTFILE "q->param(\"cdrw$i\")=".$q->param("cdrw$i")."\n";
         return "cdrw$i";
      }
   }
   return '';
}
sub getIsos() {
################################################################################
# Purpose : Figures out whether a given item in the queue contains a list of CDs,
#           or a single DVD or a CD
# Input   : medium
#         : queue item
# Output  : reference to an array of the diskHash(es)
#         : Changes medium.$device to 'DVD of CDs' for DVD media with the 'CDs' 
#           parameter set on the diskHash
# Created : Charles Oertel (2005/11/06)
# Licence : GPL
################################################################################
   my ($device) = @_;
   print OUTFILE "device=$device\n" if ($main::debug);
   my @IsoArray;
   my $medium = $cache->get("medium.$device");
   print OUTFILE "medium=$medium\n" if ($main::debug);
   my %item = %{$cache->get("queue.$device")};
   print OUTFILE "volume=$item{'Volume'}\n" if ($main::debug);
   if ($medium eq 'DVD') {
      my %DiskData = %{$item{'DVD'}};
      my @DiskArray = @{$item{'CDs'}};
      if (@DiskArray) {
         $cache->set("medium.$device", 'DVD of CDs');
         foreach $Disk (@DiskArray) {
            my %Volume = %{$Disk};
            my %DiskData = %{$Volume{'CD'}};
            my $path = $main::IsoDir.'/'.
                       $DiskData{'distro'}.'/'.
                       $DiskData{'version'}.'/'.
                       $DiskData{'medium'}.'/'.
                       $DiskData{'isoname'};
            push @IsoArray, $path;
            print OUTFILE "path=$path\n" if ($main::debug);
         }
      } else {
         my $path = $main::IsoDir.'/'.
                    $DiskData{'distro'}.'/'.
                    $DiskData{'version'}.'/'.
                    $DiskData{'medium'}.'/'.
                    $DiskData{'isoname'};
         push @IsoArray, $path;
            print OUTFILE "path=$path\n" if ($main::debug);
      }
   } else {
      my %DiskData = %{$item{'CD'}};
      my $path = $item{'Path'};
      if ($path eq '') {
         $path = $main::IsoDir.'/'.
                 $DiskData{'distro'}.'/'.
                 $DiskData{'version'}.'/'.
                 $DiskData{'medium'}.'/'.
                 $DiskData{'isoname'};
      }
      push @IsoArray, $path;
            print OUTFILE "path=$path\n" if ($main::debug);
   }
   return(\@IsoArray);
}
