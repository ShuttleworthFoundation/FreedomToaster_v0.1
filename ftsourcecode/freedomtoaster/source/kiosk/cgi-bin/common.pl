#!/usr/bin/perl
################################################################################
# List of functions in this file:
# - get_date : ?? does not seems to be used anymore ??
# - setLocaleParms : Set language domain so as gettext may returns the translated strings
# - makeVolumeBaseName : Creates a four-letter random code to give to volume labels to keep them unique
# - burnMedium : Calls the system to do a generic CD or DVD burn - new version
# - blankMedium : Blanks CDRW media
# - readDVDStatus : Assesses state of DVD Medium after writing
# - findUnmountedCD : Returns the device of any unmounted CD or DVD drive
# - unmountCDs : Unmounts and ejects all the drives
# - getMountPath : Returns the mount point path of a mounted device
# - distroVersions : For a specific distro, lists all version names, media available (CD/DVD), and medium count
# - printVersionSelect : Displays the default button or the version select screen
# - countDiscs : Count .iso files in a directory
# - showCart : Print a list of the isos that have been chosen by the client and not yet sent to the burner Queues.
# - sendDistrosTo : Put distro onto CDQueue or DVDQueue for burning straight away
# - showIsoLists : Print the CDList and DVDList of isos that are ready to be sent to the burner queues or consolidated onto DVD...
# - putCDsIntoDVD : Move isos from the CD2DVDList to DVD Isos on DVDList
# - sendListToQueue : Move isos from the CDList and DVDList to the relevant burner queues
# - showBurnerQueues : Print the CDQueue and DVDQueue that the burners (burners.pl) read
# - clearCart : Clears the list of the isos chosen by the client and not yet sent to the burner Queues.
# - clearList : Clears the list of the isos chosen by the client and not yet sent to the burner Queues.
# - shoppingCartCount : Counts number of items that have been selected but not sent to the burners
# - countQueueSize : Counts total number of items on all lists
# - KeyboardEntryField : Allows touchscreen input of text
################################################################################

use strict;
use warnings;
use POSIX ":sys_wait_h"; # make WNOHANG available
use Locale::gettext;

################################################################################
# Functions that are system-specific
################################################################################

sub get_date {
   my @days = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
   my @months = ('January','February','March','April','May','June','July',
	      'August','September','October','November','December');

   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   if ($hour < 10) { $hour = "0$hour"; }
   if ($min < 10) { $min = "0$min"; }
   if ($sec < 10) { $sec = "0$sec"; }
   $mon += 1;
   $year += 1900;

   my $date = "$year\:$mon\:$mday $hour\:$min\:$sec";
   return $date;
}

sub getCurrentLang {
################################################################################
# Purpose: Return current language selected in the FT interface (set with cookie)
# Input  : $short    -  if true, the short two-letters code is returned ("fr"), else the long version ("fr_FR.utf8") ################################################################################
   use CGI qw(:all);
   my ($short) = @_;
   my $q=new CGI;
   my $lang = $q->cookie(-name=>'FTlang');
   if ($short)	{ return substr($lang,0,2); }
   else { return $lang; }
}

sub setLocaleParms {
################################################################################
# Purpose: Set language domain so as gettext may returns the translated strings
################################################################################
   my ($lng) = @_;
   POSIX::setlocale(LC_MESSAGES, $lng);
   bindtextdomain("freedomtoaster", "../locale");
   bind_textdomain_codeset("freedomtoaster", "UTF-8");
   textdomain("freedomtoaster");
}

sub makeVolumeBaseName {
################################################################################
# Purpose: Creates a four-letter random code to give to volume labels to keep them unique
################################################################################
   my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9 );
   return join("", @chars[ map { rand @chars } ( 1 .. 4 ) ]);
}

sub burnMedium {
################################################################################
# Purpose: Calls the system to do a generic CD or DVD burn - new version
# Input  : $resource    - the cdrw device to burn to (in form cdrwn) 
#          \@distroIsos - full paths to the iso files to put onto this device
#          $medium      - CD or DVD
#          $volume      - volume identifier (for checking during updates...)
# Output : returns the string of output, AND
#          writes to /tmp/$resource the output while it is happening.  To get
#          burn progress, read /tmp/$resource and interpret it appropriately
################################################################################
   my ($resource, $distroIsos, $medium, $volume) = @_;
   my @distroISOs = @{$distroIsos};
   my $retval;
   my $isolist;
   my $burnlist;

   if ($medium eq 'CD') {
      $isolist = ','.$distroISOs[0];
      $retval = system "sudo cdrecord -s $main::CDRecordParms -v -eject -gracetime=0 -data dev=".$main::Devices{$resource}.' '. $distroISOs[0]. " > /tmp/$resource 2>&1";

      $retval = `grep '[0-9]* MB written' /tmp/$resource`;
      if (!($retval =~ s/^.*\r//)) {
	$retval .= gettext('Failed');
      } else {
        $retval =~ s/^[^:]\+:\s*//;
        $retval =~ s/written.*$/written/i;
      }

   } elsif ($medium eq 'DVD of CDs') {
      my $start = 1;
		my @distros;
      foreach my $distroISO (@distroISOs) {
         $isolist .= ','.$distroISO;
         $burnlist .= $distroISO.' '; 
			$distroISO =~ m#$main::IsoDir/([^/]*)/([^/]*)/([^/]*)/(.*)$#;
			push @distros, { 'distro' => $1, 'version' => $2, 'medium' => $3, 'file' => $4 };
      }
		my %XML;
		$XML{'distros'} = \@distros;
		use XML::Simple;
		my $xml = XMLout(\%XML);
		open (METAFILE, ">/tmp/$resource.xml");
		print METAFILE $xml;
		close METAFILE;
		$burnlist .= "/tmp/$resource.xml";
      $retval = system "sudo growisofs -dvd-compat -use-the-force-luke=tty,dao -Z ".$main::Devices{$resource}." -r -R -V $volume $burnlist > /tmp/$resource 2>&1";
      $retval = readDVDStatus($resource);

   } elsif ($medium eq 'DVD') {
      $isolist = ','.$distroISOs[0];
      $retval = system "sudo growisofs -dvd-compat -use-the-force-luke=tty,dao -Z ".$main::Devices{$resource}."=".$distroISOs[0]." > /tmp/$resource 2>&1";
      $retval = readDVDStatus($resource);
   }

   open (LOGTOAST,">>$main::LogFile"); # or die "opening $main::LogFile : $!"; 
   my $dt=`date +"%Y-%m-%d %H:%M:%S"`;
   chomp $dt;
   print LOGTOAST "$main::ToasterName,$dt,$resource,$medium,".chomp($retval).$isolist."\n";
   close LOGTOAST;

   system "sudo eject ".$main::Devices{$resource};
   return($retval);
}

sub blankMedium {
################################################################################
# Purpose: Blanks CDRW media
# Input  : $resource    - the cdrw device to blank (in form cdrwn) 
# Output : returns the string of output, AND
#          writes to /tmp/$resource the output while it is happening.  To get
#          burn progress, read /tmp/$resource and interpret it appropriately
################################################################################
   my ($resource,$medium) = @_;
   my $retval;

   if ($medium =~ m/CD/) {
      if ($retval=system("sudo cdrecord -s $main::CDRecordParms -vv -s -eject -gracetime=2 -blank=fast dev=".$main::Devices{$resource}." > /tmp/$resource 2>&1")) {
         $retval = system("sudo cdrecord -s $main::CDRecordParms -vv -s -eject -gracetime=2 -force -blank=all dev=".$main::Devices{$resource}." > /tmp/$resource 2>&1");
      } 
      if ($retval eq 0) {
         $retval = gettext("Disk Blanked");
      } else {
         $retval = gettext("Blanking failed");
      }
   } elsif ($medium =~ m/DVD/) {
	   $retval = system "sudo mount ".$main::Devices{$resource}." && sudo dvd+rw-format -blank ".$main::Devices{$resource}." > /tmp/$resource 2>&1";

      $retval = `tail -1 /tmp/$resource | sed 's/.*\r//'`;
      chomp $retval;
      system "sudo eject ".$main::Devices{$resource};
   }
   return($retval);
}

sub readDVDStatus {
################################################################################
# Purpose: Assesses state of DVD Medium after writing
# Input  : $device    - the cdrw device, loaded (not ejected)
# Output : returns the status string for display on burners, AND
#          sets erasable.$device in the cache
################################################################################
   my ($resource) = @_;
   
   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Can't create file cache in newKiosk namespace";

   system "sudo mount ".$main::Devices{$resource};
   system "dvd+rw-mediainfo ".$main::Devices{$resource}." > /tmp/mediainfo.$resource 2>&1";
   if (`grep 'Mounted Media' /tmp/mediainfo.$resource | grep -c RW`) {
      $cache->set("erasable.$resource", 1);
   } else {
      $cache->set("erasable.$resource", 0);
   }
   return `grep 'State of Last Session:' /tmp/mediainfo.$resource | sed 's/.*: //' `;
}
sub findUnmountedCD {
################################################################################
# Purpose: Returns the device of any unmounted CD or DVD drive
# Input  : config.pl with a list of CDROMs configured
# Output : the first available device
# Created: Charles Oertel (2005/11/07) FineBushPeople.net
################################################################################
   my $cdrw;
   foreach $cdrw (keys %main::Devices) {
      if (system("mount | grep ".$main::Devices{$cdrw}." 2>/dev/null 1>&2")) {
         return $main::Devices{$cdrw};
      }
   }
}
sub unmountCDs {
################################################################################
# Purpose: Unmounts and ejects all the drives
# Input  : config.pl with a list of CDROMs configured
# Output : All drives are ejected
# Remarks: During some operations, the machine mounts a CD then does not unmount
#          it.  This function will be callable from the admin screen to allow
#          an admin to clear the machine's mounts.
# Created: Charles Oertel (2006/06/07) FineBushPeople.net
################################################################################
   my $cdrw;
   foreach $cdrw (keys %main::Devices) {
      if (system("eject ".$main::Devices{$cdrw}." 2>/dev/null 1>&2")) {
         system("umount ".$main::Devices{$cdrw}); 
	 system("eject ".$main::Devices{$cdrw}); 
      }
   }
}
sub getMountPath {
################################################################################
# Purpose: Returns the mount point path of a mounted device
# Input  : $device - the mounted device
# Output : returns the mount point
# Created: Charles Oertel (2005/11/07) FineBushPeople.net
################################################################################
   my ($device) = @_;
   my $retval = `mount | grep $device | egrep -o 'on [^ ]*' | sed 's/on //'`;
   chomp($retval);
   return $retval;
}

sub distroVersions {
################################################################################
# Purpose: For a specific distro, lists all version names, media available (CD/DVD), and medium count
# Input  : $distro   - name of distro (= name of folder in isos directory)
################################################################################
   my ($distro) = @_;
   my (@Versions,@RadioValues,%RadioLabels);
   my %Info;

   opendir(DIR, "$main::IsoDir/$distro") or die "unable to read $main::IsoDir/$distro : $!";
   for (readdir(DIR)) {
      next if (/^\./);
      if (-d "$main::IsoDir/$distro/$_") {
         push @Versions,$_;
      }
   }
   close(DIR);
   my $first = 1; 
   my $DefaultVersion="";
   foreach my $Version (sort {$b cmp $a} @Versions) {
      opendir(DIR, "$main::IsoDir/$distro/$Version") or die "Unable to open $main::IsoDir/$distro/$Version : $!"; 
      for (readdir(DIR)) {
         next if (/^\./);
         my $medium = $_;
         if (-d "$main::IsoDir/$distro/$Version/$medium") { # a directory with CD or DVD isos.
            my $count = countDiscs("$main::IsoDir/$distro/$Version/$medium");
            next if (!$count);
            $Info{$Version}{$medium}{'NumDisks'} = $count;
            my $RBValue = "$distro|$Version|$medium|$count";
            push @RadioValues, $RBValue;
            $RadioLabels{$RBValue} = "$Version ".sprintf(ngettext("(%d %s)","(%d %ss)",$count),$count,$medium);
            if ($first) {
               $first = 0;
               $DefaultVersion = $RBValue;
            }
         }
      }
      close(DIR);
   }
   use XML::Simple;
   my $xml = new XML::Simple(KeyAttr=>[]);
   my $lang = getCurrentLang(1);
   my $distroInfo;
   if ( -e "$main::IsoDir/$distro/$distro-$lang.xml" ) 	{
   	$distroInfo = $xml->XMLin("$main::IsoDir/$distro/$distro-$lang.xml");
   } else {
   	$distroInfo = $xml->XMLin("$main::IsoDir/$distro/$distro.xml");
   }   
   if (defined($distroInfo->{defaults})) {
      $DefaultVersion = $distroInfo->{defaults}{defaultVersion};
   }

   return \(@Versions,@RadioValues,%RadioLabels,$DefaultVersion);
}


sub printVersionSelect() {
################################################################################
# Purpose: Displays the default button or the version select screen
# Input  : $RadioValues    - Array of pipe-delimited version values
#          $RadioLabels    - Array of version labels for display in list box
#          $DefaultVersion - The pipe-delimited version info of the default
#          $OnlyDefault    - Set to true to only show 'toast default' button
################################################################################
   my ($Versions,$RadioValues,$RadioLabels,$DefaultVersion,$OnlyDefault) = @_;
   my @RadioValues = @{$RadioValues};
   my %RadioLabels = %{$RadioLabels};
   $DefaultVersion = ${$DefaultVersion};
   
   use CGI qw(:all);
   my $q = new CGI;
   my $lang = $q->cookie(-name=>'FTlang');
   setLocaleParms($lang);
   my $ImageURL = "../locale/".substr($lang,0,2)."/images";

   print $q->start_form(-action=>$main::CGIURL."/ok.pl", -method=>'POST');
   print $q->start_div({-id=>'distroVersion'});
   my ($distro,$version,$medium,$count) = split /\|/, $DefaultVersion;
   if ($OnlyDefault) {
      my $DefaultName = "$distro $version ".sprintf(ngettext("(%d %s)","(%d %ss)",$count),$count,$medium);
      print $q->h2({-style=>'text-align:center;color:white'}, $DefaultName);
      print $q->image_button(-name=>"ToastDefault", -value=>"1", -src=>$ImageURL."/add_to_selection.png");
      print $q->hidden(-name=>"distroVersion", -value=>"$DefaultVersion");
      print $q->br();
      print $q->br();
      print $q->br();
      print $q->image_button(-name=>"Advanced", -value=>"1", -src=>$ImageURL."/other_versions.png");
   } else {
      my $VersionListSize = (@RadioValues>10) ? 10 : 4;
      print $q->h1(sprintf(gettext("Choose %s Version"),$distro));
      print $q->scrolling_list(-name=>'distroVersion',
                               -values=>\@RadioValues,
                               -default=>$RadioValues[0],
                               -size=>$VersionListSize,
                               -multiple=>'false',
                               -labels=>\%RadioLabels);
      print $q->br(),$q->br();
      print $q->hidden(-name=>"Advanced", -value=>"1");
      print $q->image_button(-name=>"DoItNow", -value=>"1", -src=>$ImageURL."/add_to_selection.png");
   }
   print $q->end_div;
   print $q->start_div({-id=>"next"});
   print $q->image_button(-name=>"ToastDefault", -value=>"1", -src=>$main::CSSURL."/images/R_button.gif");
   print $q->end_div;
   print $q->end_form;
}

sub countDiscs () {
   my ($Directory) = @_;
	my $numdiscs=0;
	opendir (DIR,$Directory) or die ("Can't open the directory: $Directory\n");
	while ( defined ( my $file = readdir(DIR) ) ) { 
		next if $file !~ /\.iso$/;
		$numdiscs++;
	}     
	closedir(DIR);
	return $numdiscs;
}   

sub showCart {
################################################################################
# Purpose: Print a list of the isos that have been chosen by the client and not
#          yet sent to the burner Queues.
# Input  : Cache::FileCache with elements in distroVersion and distroDisks
# Output : HTML listing of the contents of the queue
# Remarks: Once an item is on this queue the user needs to release it to the 
#          burners before anything will happen.
# Created: Charles Oertel, copyright 2006/02/04
# License: GPL and Creative Commons with attribution
################################################################################
   use Cache::FileCache;
   use CGI qw(:all);
   my $q = new CGI;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";

   my @distroVersions = @{$cache->get('distroVersion')} if defined($cache->get('distroVersion'));
   my @distroDisks = @{$cache->get('distroDisks')} if defined($cache->get('distroDisks'));

   print $q->start_form(-name=>"CartForm", -action=>$main::CGIURL."/showQueue.pl", -method=>'POST');
   print $q->hidden(-name=>"task", -value=>"");
   print "<div class=\"DVDQueue\">";
   print $q->h2(gettext("Shopping Cart").sprintf(ngettext(" (%d item)"," (%d items)",int(@distroDisks)), int(@distroDisks)));
   
   my @DistroListValues;
   my %DistroListLabels;

   foreach my $distroVersion (@distroVersions) {
      my ($distro,$version,$medium,$diskcount) = split /\|/, $distroVersion;
      my $Value = "$distro $version ".sprintf(ngettext("(%d %s)","(%d %ss)",$diskcount),$diskcount,$medium);
      push  @DistroListValues, $Value;
      $DistroListLabels{$Value} = $Value;
   }
   print $q->scrolling_list(-name=>'DistroList',
                            -values=>\@DistroListValues,
                            -labels=>\%DistroListLabels,
                            -size=>4);
   print "</div></form>";
}

sub sendDistrosTo {
################################################################################
# Purpose: Put distro onto CDQueue or DVDQueue for burning straight away
# Input  : $Queue - either 'Queue' or 'List', where:
#                   'Queue' will send distros to CDQueue and DVDQueue for burn
#                   'List' will send them to CDList and DVDList for advanced
#          Cache::FileCache with elements in distroVersion and distroDisks
# Output : Cache::FileCache CDQueue and DVDQueue loaded with isos 
# Remarks: Distros in the input lists (distroVersion) are exploded into
#          the number of isos that make up the distro, with full path details,
#          and sent to the CDQueue or the DVDQueue depending on what medium
#          each iso is for.
# Created: Charles Oertel, copyright 2006/02/04
# License: GPL and Creative Commons with attribution
################################################################################
   my ($Queue) = @_;
   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   my @distroVersions = @{$cache->get('distroVersion')} if defined($cache->get('distroVersion'));
   my @distroDisks = @{$cache->get('distroDisks')} if defined($cache->get('distroDisks'));
   my @CDQueue = @{$cache->get('CD'.$Queue)} if defined($cache->get('CD'.$Queue));
# DVDs always go straight to the Queue for burning, regardless of whether $Queue is set to
# 'List' or 'Queue' because there is no sense in putting DVDs onto a combined DVD
   my @DVDQueue = @{$cache->get('DVDQueue')} if defined($cache->get('DVDQueue'));

   my $index = 0;
   foreach my $distroVersion (@distroVersions) {
      my ($distro,$version,$medium,$diskcount) = split /\|/, $distroVersion;
      my @Disks = @{$distroDisks[$index]};
      $index++;
      my $diskno = 0;
      foreach my $disk (@Disks) {
         $diskno++;
         my $volume = "$distro-$version-${diskno}of$diskcount";
         my %diskHash =   (distro   =>	$distro,
                           version	=> $version,
                           medium	=> $medium,
                           total	   => $diskcount,
                           diskno	=> $diskno,
                           isoname	=> $disk);
         if ($medium eq 'CD') { 
               my %volumeHash = (Volume=>$volume, CD=>\%diskHash);
               push @CDQueue, \%volumeHash;
         } elsif ($medium eq 'DVD') {
            my %volumeHash = (Volume=>$volume, DVD=>\%diskHash);
            push @DVDQueue, \%volumeHash;
         }
      }
   }
   $cache->set('CD'.$Queue, \@CDQueue);
   $cache->set('DVDQueue', \@DVDQueue);
   clearCart();
}

sub showIsoLists {
################################################################################
# Purpose: Print the CDList and DVDList of isos that are ready to be send to 
#          the burner queues or consolidated onto DVD...
# Input  : Advanced - undefined or true, true means show advanced options...
#          Cache::FileCache with elements in CDList and DVDList
# Output : HTML listing of the contents of the queues
# Remarks: Items get onto this list by being packaged from the distroVersion and
#          distroDisks lists by `sendDistrosTo('List')
# Created: Charles Oertel, copyright 2006/02/05
# License: GPL and Creative Commons with attribution
################################################################################
   my ($Advanced) = @_;

   use Cache::FileCache;
   use CGI qw(:all);
   my $q = new CGI;
   my $lang = $q->cookie(-name=>'FTlang');
   my $ImageURL = "../locale/".substr($lang,0,2)."/images";
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   my @DVDQueue = @{$cache->get('DVDList')} if defined($cache->get('DVDList'));
   my @CDQueue = @{$cache->get('CDList')} if defined($cache->get('CDList'));
   my @CD2DVDQueue = @{$cache->get('CD2DVDList')} if defined($cache->get('CD2DVDList'));

   print $q->start_form(-action=>$main::CGIURL."/showQueue.pl", -method=>'POST',
                        -name=>"ListForm");
   print $q->hidden(-name=>"task", -value=>"ToastAll");
   print $q->hidden(-name=>"selectedIndex", -value=>"");
   my $CDCount = int(@CDQueue);
   my $AdvancedStyle = ' ';
   $AdvancedStyle = 'style="width:40%"' if ($Advanced);
   print "<div class=\"DVDQueue\" $AdvancedStyle><h2>".sprintf(ngettext("%d CD ISO Selected","%d CD ISOs Selected",$CDCount),$CDCount)."</h2>";
   my @CDQueueValues;
   my %CDQueueLabels;
   foreach my $CDHash (@CDQueue) {
      my %CD = %{$CDHash};
      my $Value;
      if (defined($CD{'CD'})) {
         my %DiskData = %{$CD{'CD'}};
         $Value = $DiskData{'distro'}. " ". 
                  $DiskData{'version'}. " (". 
                  $DiskData{'medium'}. " ". 
                  $DiskData{'diskno'}. gettext(" of "). 
                  $DiskData{'total'}. ")";
      } elsif (defined($CD{'Path'})) {
         $Value = gettext("Iso Path: "). $CD{'Path'};
      }
      push  @CDQueueValues, $Value;
      $CDQueueLabels{$Value} = $Value;
   }
   print $q->scrolling_list(-name=>'CDQueueList',
                            -values=>\@CDQueueValues,
                            -labels=>\%CDQueueLabels,
                            -size=>4);
   print $q->p({-style=>"font-size:80%;margin:0 .3em"},gettext("Select CD isos to put onto DVD then click 'Add to DVD'. Click 'Toast Selection' below when done:  the remaining CDs and any DVD collections will be sent to the queue for toasting."));
   print $q->image_button(-name=>"Clear CD List", -title=>gettext("Clear All Items in CD List"), -src=>$ImageURL."/clear_list.png", -onclick=>"document.ListForm.task.value='ClearCDList';document.ListForm.submit();");
   print "</div>";

   if ($Advanced) {
### Buttons between the boxes...
      my $CD2DVDButton = $q->img({-src=>$ImageURL."/add_to_dvd_disabled.png", -style=>"width:136px"});
      my $DVD2CDButton = $q->img({-src=>$ImageURL."/put_back_disabled.png", -style=>"width:136px"});
      if (@CDQueue) {
         $CD2DVDButton = $q->image_button(-style=>"width:136px", -name=>"Move to DVD", -title=>gettext("Move to DVD"), -src=>$ImageURL."/add_to_dvd.png", -onclick=>"document.ListForm.task.value='AddCDtoDVD';document.ListForm.selectedIndex.value=document.ListForm.CDQueueList.selectedIndex;document.ListForm.submit();");
      }
      if (@CD2DVDQueue) {
         $DVD2CDButton = $q->image_button(-style=>"width:136px", -name=>"Remove from DVD", -title=>gettext("Remove from DVD"), -src=>$ImageURL."/put_back.png", -onclick=>"document.ListForm.task.value='RemCDfromDVD';document.ListForm.selectedIndex.value=document.ListForm.CD2DVDQueueList.selectedIndex;document.ListForm.submit();");
      }
      print $q->div({-style=>"width:136px;float:left;padding-top:40px"},
            $CD2DVDButton,
            $q->br(),
            $q->br(),
            $DVD2CDButton);
### /Buttons
      my $CD2DVDCount = int(@CD2DVDQueue);
      print "<div class=\"DVDQueue\" style=\"float:right;width:40%\"><h2>".sprintf(ngettext("%d CD to combine on DVD","%d CDs to combine on DVD",$CD2DVDCount),$CD2DVDCount)."</h2>";
      my @CDQueueValues;
      my %CDQueueLabels;
      foreach my $CDHash (@CD2DVDQueue) {
         my %CD = %{$CDHash};
         my $Value;
         if (defined($CD{'CD'})) {
            my %DiskData = %{$CD{'CD'}};
            $Value = $DiskData{'distro'}. " ". 
                     $DiskData{'version'}. " (". 
                     $DiskData{'medium'}. " ". 
                     $DiskData{'diskno'}. gettext(" of "). 
                     $DiskData{'total'}. ")";
         } elsif (defined($CD{'Path'})) {
            $Value = gettext("Iso Path: "). $CD{'Path'};
         }
         push  @CDQueueValues, $Value;
         $CDQueueLabels{$Value} = $Value;
      }
      print $q->scrolling_list(-name=>'CD2DVDQueueList',
                              -values=>\@CDQueueValues,
                              -labels=>\%CDQueueLabels,
                              -size=>4);
      my $DVDsRequired = putCDsIntoDVD('CD2DVDList', 'DVDList', 'MyCDsOnDVD', 1);
      print $q->p({-style=>"font-size:90%;text-align:center;margin:.2em"},sprintf(ngettext("Requires %d DVD","Requires %d DVDs",$DVDsRequired), $DVDsRequired));
      print $q->p({-style=>"font-size:80%;margin:0 .3em"},gettext("The DVDs are not bootable and special steps are needed to install a system with them.  If you are in doubt then this is not for you."));
      print $q->image_button(-name=>"Clear CD to DVD List", -title=>gettext("Clear All Items in this list"), -src=>$ImageURL."/clear_list.png", -onclick=>"document.ListForm.task.value='ClearCD2DVDList';document.ListForm.submit();");
      print "</div>";
   }

#   my $DVDCount = int(@DVDQueue);
#   $s = (@DVDQueue eq 1) ? '' : 's';
#   print "<div class=\"DVDQueue\" $AdvancedStyle><h2>".sprintf(gettext("%d DVD ISO%s Selected"),$DVDCount,$s)."</h2>";
#   my @DVDQueueValues;
#   my %DVDQueueLabels;
#   foreach my $DVDHash (@DVDQueue) {
#      my %DVD = %{$DVDHash};
#      my @DiskArray = @{$DVD{'CDs'}} if defined($DVD{'CDs'});
#      my $Value;
##
#      if (@DiskArray) {
#         foreach my $Disk (@DiskArray) {
#            my %DiskData = %{$Disk};
#            $Value = $DiskData{'distro'}. " ". 
#                     $DiskData{'version'}. " (". 
#                     $DiskData{'diskno'}. " of ". 
#                     $DiskData{'total'}. ")"; 
#            push  @DVDQueueValues, $Value;
#            $DVDQueueLabels{$Value} = $Value;
#         }
#      } else {
#         my %DiskData = %{$DVD{'DVD'}};
#         my $Value = $DiskData{'distro'}. " ". 
#                     $DiskData{'version'}. " (". 
#                     $DiskData{'diskno'}. " of ". 
#                     $DiskData{'total'}. ")"; 
#         push  @DVDQueueValues, $Value;
#         $DVDQueueLabels{$Value} = $Value;
#      }
#   }
#   print $q->scrolling_list(-name=>'DVDQueueList',
#                            -values=>\@DVDQueueValues,
#                            -labels=>\%DVDQueueLabels,
#                            -size=>4);
#   print $q->image_button(-name=>"Clear DVD List", -title=>gettext("Clear All Items in this list"), -src=>$ImageURL."/clear_list.png", -onclick=>"document.ListForm.task.value='ClearDVDList';document.ListForm.submit();");
#   print "</div>\n";
 
   print $q->end_form;
   print "<br clear=\"all\" />\n";
}

sub putCDsIntoDVD {
################################################################################
# Purpose: Move isos from the CD2DVDList to DVD Isos on DVDList
# Input  : Cache::FileCache with elements in CD2DVDList or CDList (whatever you
#          you set the value of '$Source' to.
#          $Source    - which list to get the CD isos from, either
#                       CDList or CD2DVDList
#          $Destination which list to put the DVDs onto: DVDList or DVDQueue
#          $VolumeBase- the prefix of the volume names to have 00n appended
#          $CountOnly - do not move the CD isos, just count how many DVDs would
#                       be created from the CD2DVDList
# Output : Cache::FileCache with CDs removed from CD2DVDList and DVD isos added 
#          to DVDQueue
# Return : Number of DVDs that would be needed for the contents of CD2DVDList
# Remarks: Set $CountOnly to get a count of the number of DVDs that are needed.
#
#          We look at the size of each CD and put them into an array so that 
#          we can have a variable number of CDs on a DVD.  The algorithm is:
#          0. Sort in descending size.  
#          1. Starting at the beginning of the list (i.e. the largest ISO):
#             a. If the iso size is smaller than the remaining space on the DVD,
#                put the iso into the array for that DVD and remove it from the 
#                list of CDs.
#             b. ELSE skip to the next iso in the list etc. Only putting in isos 
#                that will fit and progressively trying smaller isos until you 
#                reach the end of the list.
#          2. Start 1. again on a fresh DVD with the remainder of the list, 
#             until there are no more CDs in the list
#    
# Created: Charles Oertel, copyright 2006/02/05
# License: GPL and Creative Commons with attribution
################################################################################
   my ($Source, $Destination, $VolumeBase, $CountOnly) = @_;

   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   my @CD2DVDList = @{$cache->get($Source)} if defined($cache->get($Source));
   my @DVDQueue = @{$cache->get($Destination)} if defined($cache->get($Destination));
   my $VolumeCount = 0;
   my %SizeHash;
   my $index = 0;
   foreach my $CD (@CD2DVDList) {
      my %volume = %{$CD};
      my %cd = %{$volume{'CD'}} if defined($volume{'CD'});
      my ($size) = (stat($main::IsoDir.'/'.$cd{'distro'}.'/'.$cd{'version'}.'/'.$cd{'medium'}.'/'.$cd{'isoname'}))[7];
      $SizeHash{$index} = $size;
      $index += 1;
   }
   my @keys = (sort { $SizeHash{$b} <=> $SizeHash{$a} } keys %SizeHash);
   my %AllocatedKeys;
   my $CDsToGo = @CD2DVDList;
   while ($CDsToGo) {
      my $DVDSpace = 4700000000;
      my @VolumeCDs;
      foreach my $key (@keys) {
         next if ($AllocatedKeys{$key});
#   print p("Size of $key is ".$SizeHash{$key});
         if ($DVDSpace >= $SizeHash{$key}) {
            $DVDSpace -= $SizeHash{$key};
#               print p("$key is ".$SizeHash{$key}." big and space left is: $DVDSpace, CDsToGo=$CDsToGo");
            push @VolumeCDs, \%{$CD2DVDList[$key]};
            $AllocatedKeys{$key} = 1;
            $CDsToGo--;
         }
      }
      $VolumeCount++;
      my $VolumeName = $VolumeBase.sprintf("%03d", $VolumeCount);
      my %Volume = (Volume=>$VolumeName, CDs=>\@VolumeCDs);
#
#      print p("Doing volume $Volume{'Volume'}, with ", int @VolumeCDs, " CDs");
#         print p("Space on DVD left is: $DVDSpace");
#
      push @DVDQueue, \%Volume;
   }
   undef(@CD2DVDList);
   if (!$CountOnly) {
      $cache->set($Destination, \@DVDQueue);
      $cache->set($Source, \@CD2DVDList);
   }
   return($VolumeCount);
}

sub sendListToQueue {
################################################################################
# Purpose: Move isos from the CDList and DVDList to the relevant burner queues
# Input  : Cache::FileCache with elements in CDList and DVDList
# Output : Cache::FileCache with elements in CDQueue and DVDQueue
# Remarks: Also reads the actual volume name of the ISO so that it can be used
#          for admin updates and as a label for the disk
# Created: Charles Oertel, copyright 2006/02/05
# License: GPL and Creative Commons with attribution
################################################################################
   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   my @DVDList = @{$cache->get('DVDList')} if defined($cache->get('DVDList'));
   my @CDList = @{$cache->get('CDList')} if defined($cache->get('CDList'));
   my @DVDQueue = @{$cache->get('DVDQueue')} if defined($cache->get('DVDQueue'));
   my @CDQueue = @{$cache->get('CDQueue')} if defined($cache->get('CDQueue'));

# first make sure we have a mount point...
#
   if (! -e '/mnt/iso') {
      mkdir '/mnt/iso';
   }
   foreach my $DVDHash (@DVDList) {
      my %DVDHash = %{$DVDHash};
      if (defined($DVDHash{'DVD'})) { # it's a DVD iso, not a list of CDs on DVD...
         my %DiskData = %{$DVDHash{'DVD'}};
         my $IsoPath = $main::IsoDir.'/'.
                     $DiskData{'distro'}.'/'.
                     $DiskData{'version'}.'/'. 
                     $DiskData{'medium'}.'/'. 
                     $DiskData{'isoname'};
         system("sudo /bin/umount /mnt/iso");
         system("sudo /bin/mount -t auto -oloop $IsoPath /mnt/iso");
         my $VolumeName = `sudo /usr/bin/volname /dev/loop0`;
         chomp($VolumeName);
         system("sudo /bin/umount /mnt/iso");
         my %Volume = (Volume=>$VolumeName, DVD=>\%DiskData);
         push @DVDQueue, \%Volume;
      } else { # The list of CDs on DVD is already in volume format...
         push @DVDQueue, $DVDHash;
      }
   }
      
   ### if any CDs still in array (cos medium ne DVD), push them onto CDQueue
   foreach my $CDHash (@CDList) {
      my %CDHash = %{$CDHash};
      my %DiskData = %{$CDHash{'CD'}};
      my $IsoPath = $main::IsoDir.'/'.
                    $DiskData{'distro'}.'/'.
                    $DiskData{'version'}.'/'. 
                    $DiskData{'medium'}.'/'. 
                    $DiskData{'isoname'};
      system("sudo /bin/umount /mnt/iso");
      system("sudo /bin/mount -t auto -oloop $IsoPath /mnt/iso");
      my $VolumeName = `sudo /usr/bin/volname /dev/loop0`;
      chomp($VolumeName);
      system("sudo /bin/umount /mnt/iso");
      my %Volume = (Volume=>$VolumeName, CD=>\%DiskData);
      push @CDQueue, \%Volume;
   }
   $cache->set('DVDQueue', \@DVDQueue);
   $cache->set('CDQueue', \@CDQueue);
   clearList();
}

sub showBurnerQueues {
################################################################################
# Purpose: Print the CDQueue and DVDQueue that the burners (burners.pl) read
#          from to get the next iso to toast.
# Input  : Cache::FileCache with elements in CDQueue and DVDQueue
# Output : HTML listing of the contents of the queue
# Remarks: Once an item is on this queue it will automatically get sent to
#          a burner with the capability of burning it (i.e. only DVD-RW
#          devices take items off the DVDQueue)
# Created: Charles Oertel, copyright 2006/02/04
# License: GPL and Creative Commons with attribution
################################################################################
   use Cache::FileCache;
   use CGI qw(:all);
   my $q = new CGI;
   my $lang = $q->cookie(-name=>'FTlang');
   my $ImageURL = "../locale/".substr($lang,0,2)."/images";

   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   my @DVDQueue = @{$cache->get('DVDQueue')} if defined($cache->get('DVDQueue'));
   my @CDQueue = @{$cache->get('CDQueue')} if defined($cache->get('CDQueue'));

   print $q->start_form(-name=>'QueueForm', -action=>$main::CGIURL."/showQueue.pl", -method=>'POST');
   print $q->hidden(-name=>'task', -value=>'');
   print '<div id="BurnerQueues">';
   my $CDCount = int(@CDQueue);
   print "<div class=\"DVDQueue\"><h2>".sprintf(ngettext("%d CD waiting to toast","%d CDs waiting to toast",$CDCount), $CDCount)."</h2>\n";
   my @CDQueueValues;
   my %CDQueueLabels;
   foreach my $CDHash (@CDQueue) {
      my %CD = %{$CDHash};
      my $Value;
      if (defined($CD{'CD'})) {
         my %DiskData = %{$CD{'CD'}};
         $Value = $DiskData{'distro'}. " ". 

                  $DiskData{'version'}. " (". 
                  $DiskData{'medium'}. " ". 
                  $DiskData{'diskno'}. gettext(" of "). 
                  $DiskData{'total'}. ")";
      } elsif (defined($CD{'Path'})) {
         $Value = gettext("Iso Path: "). $CD{'Path'};
      }
      push  @CDQueueValues, $Value;
      $CDQueueLabels{$Value} = $Value;
   }
   print $q->scrolling_list(-name=>'CDQueueList',
                            -values=>\@CDQueueValues,
                            -labels=>\%CDQueueLabels,
                            -size=>4);
   print $q->image_button(-name=>"Clear CD Toaster Queue", -title=>gettext("Clear All Items in this queue"), -src=>$ImageURL."/clear_list.png", -onclick=>"document.QueueForm.task.value='ClearCDQueue';document.QueueForm.submit();");
   print "</div>";
   my $DVDCount = int(@DVDQueue);
   print "<div class=\"DVDQueue\"><h2>".sprintf(ngettext("%d DVD waiting to toast","%d DVDs waiting to toast",$DVDCount),$DVDCount)."</h2>\n";
   my @DVDQueueValues;
   my %DVDQueueLabels;
   foreach my $DVDHash (@DVDQueue) {
      my %DVD = %{$DVDHash};
      my @DiskArray = @{$DVD{'CDs'}} if defined($DVD{'CDs'});
      my $Value = $DVD{'Volume'}.' ';
#
      if (@DiskArray) {
         $Value .= ':';
         push  @DVDQueueValues, $Value;
         $DVDQueueLabels{$Value} = $Value;
         foreach my $Disk (@DiskArray) {
            my %Volume = %{$Disk};
            my %DiskData = %{$Volume{'CD'}};
            $Value = '- '.$DiskData{'distro'}. " ". 
                     $DiskData{'version'}. " (". 
                     $DiskData{'diskno'}. ")"; 
            push  @DVDQueueValues, $Value;
            $DVDQueueLabels{$Value} = $Value;
         }
      } else {
         my %DiskData = %{$DVD{'DVD'}};
         $Value = $DiskData{'distro'}. " ". 
                     $DiskData{'version'}. " (". 
                     $DiskData{'diskno'}. gettext(" of "). 
                     $DiskData{'total'}. ")"; 
         push  @DVDQueueValues, $Value;
         $DVDQueueLabels{$Value} = $Value;
      }
   }
   print $q->scrolling_list(-name=>'DVDQueueList',
                            -values=>\@DVDQueueValues,
                            -labels=>\%DVDQueueLabels,
                            -size=>4);
   print $q->image_button(-name=>"Clear DVD Toaster Queue", -title=>gettext("Clear All Items in this queue"), -src=>$ImageURL."/clear_list.png", -onclick=>"document.QueueForm.task.value='ClearDVDQueue';document.QueueForm.submit();");
   print "</div>\n";
   print "</div>\n";
   print $q->end_form;
   print "<br clear=\"all\" />\n";
}

sub clearCart {
################################################################################
# Purpose: Clears the list of the isos chosen by the client and not
#          yet sent to the burner Queues.
# Input  : Cache::FileCache with elements in distroVersion and distroDisks
# Output : Empty distroVersion and distroDisks on FileCache
# Created: Charles Oertel, copyright 2006/02/04
# License: GPL and Creative Commons with attribution
################################################################################
   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   $cache->remove('distroVersion');
   $cache->remove('distroDisks');
}

sub clearList {
################################################################################
# Purpose: Clears the list of the isos chosen by the client and not
#          yet sent to the burner Queues.
# Input  : Cache::FileCache with elements in distroVersion and distroDisks
# Output : Empty distroVersion and distroDisks on FileCache
# Created: Charles Oertel, copyright 2006/02/04
# License: GPL and Creative Commons with attribution
################################################################################
   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   $cache->remove('CDList');
   $cache->remove('DVDList');
}
sub shoppingCartCount {
################################################################################
# Purpose: Counts number of items that have been selected but not sent to the
#          burners
# Input  : Cache::FileCache 
# Output : Count - total number of items in input lists
# Remarks: This helps you detect when the user has items that are waiting for 
#          him/her to press the 'Toast Selection' button.  Use this to display
#          the animated idiot arrow to the button.
# Created: Charles Oertel, copyright 2006/02/18
# License: GPL and Creative Commons with attribution
################################################################################
   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   my @DVDList = @{$cache->get('DVDList')} if defined($cache->get('DVDList'));
   my @CDList = @{$cache->get('CDList')} if defined($cache->get('CDList'));
   my @CD2DVDList = @{$cache->get('CD2DVDList')} if defined($cache->get('CD2DVDList'));
   my $total = @DVDList + @CDList + @CD2DVDList;
   return($total);
}
sub countQueueSize {
################################################################################
# Purpose: Counts total number of items on all lists
# Input  : Cache::FileCache 
# Output : Count - total number of items in all lists
# Remarks: This helps you detect when there is nothing queued so that you can
#          detect idleness ('The devil finds work for idle hands').
# Created: Charles Oertel, copyright 2006/02/18
# License: GPL and Creative Commons with attribution
################################################################################
   use Cache::FileCache;
   my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
   my @DVDList = @{$cache->get('DVDList')} if defined($cache->get('DVDList'));
   my @CDList = @{$cache->get('CDList')} if defined($cache->get('CDList'));
   my @CD2DVDList = @{$cache->get('CD2DVDList')} if defined($cache->get('CD2DVDList'));
   my @DVDQueue = @{$cache->get('DVDQueue')} if defined($cache->get('DVDQueue'));
   my @CDQueue = @{$cache->get('CDQueue')} if defined($cache->get('CDQueue'));
   my $total = @DVDList + @CDList + @CD2DVDList + @DVDQueue + @CDQueue;
   return($total);
}

sub KeyboardEntryField {
################################################################################
# Purpose: Allows touchscreen input of text
# Input  : $FieldName - the html form name of the text field to be written 
# Output : $Return    - the string containing the HTML for the field
# Remarks: This needs to be output in the context of a form so that the input
#          can be submitted
# Created: Charles Oertel, copyright 2006/05/18
# License: GPL and Creative Commons with attribution
################################################################################
   my ($FieldName) = @_;

   use CGI qw(:all);
   my $q = new CGI;
   my $letter;

   my $Return = $q->input({name=>$FieldName,value=>''});
   $Return .= $q->start_table({-cellspacing=>'7'});

   my $colCount=0;
   my $numCols=11;
   foreach $letter qw(1 2 3 4 5 6 7 8 9 0 <- q w e r t y u i o p - . a s d f g h j k l _ . z x c v b n m . . <-) {
      my $ClickJS = "document.forms[0].$FieldName.value+='$letter'";
      my $DeleteJS = "document.forms[0].$FieldName.value=document.forms[0].$FieldName.value.substring(0,document.forms[0].$FieldName.value.length-1)";
      if (!$colCount%$numCols) {
         $Return .= $q->start_Tr();
      }
      $colCount+=1;
      if ($letter ne '<-') {
	 $Return .= td(button(-class=>'key', -name=>"$letter", -value=>"$letter", -onClick=>$ClickJS));
      } else {
	 $Return .= td(button(-class=>'key', -name=>$letter, -value=>"$letter", -onClick=>$DeleteJS));
      }
      if (!($colCount%$numCols)) {
         $Return .= $q->end_Tr();
      }
   }
   if ($colCount%10) {
      $Return .= $q->end_Tr();
   }
   $Return .= $q->end_table();
   return($Return);
}

return 1;
