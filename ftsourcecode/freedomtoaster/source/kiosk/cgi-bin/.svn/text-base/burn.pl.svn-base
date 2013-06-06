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
if ($task ne 'burn') {
	if ($burnMedium = $q->param('burnMedium')) {
	   $cache->set('burnMedium', $burnMedium);
	} 
	$burnMedium = $cache->get('burnMedium');
	if ($VolumeBaseName = $q->param('VolName')) {
	   $cache->set('VolumeBaseName', $VolumeBaseName);
	} 
	$VolumeBaseName = $cache->get('VolumeBaseName');
} else {
   $VolumeBaseName = makeVolumeBaseName();
}


print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");

print $q->start_html(-title=>gettext("Burn Update"), 
				-encoding=>"UTF-8",
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL."/images/H_button.gif"})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::CGIURL."/admin.pl"},
               $q->img({-name=>'back', -src=>$main::CSSURL."/images/L_button.gif"})));

################################################################################
# Display the screen
################################################################################
print $q->start_div({-id=>'admin'});
print $q->h1(gettext("Burn some Updates"));
 
if ($task eq 'burn') {
   selectMedium();
} else {
### Start of sendDistrosToQueues 
   print $q->p(sprintf(gettext("Bundling to %s."),$burnMedium));
   my @distroVersions = @{$cache->get('distroVersion')};
   my @distroDisks = @{$cache->get('distroDisks')};
   $cache->remove('distroVersion');
   $cache->remove('distroDisks');
#
#   foreach $Disk (@distroDisks) {
#      my @disk = @{$Disk};
#      print p("Number of disks = $#disk");
#      foreach $iso (@disk) {
#         print p("Iso=$iso");
#      }
#   }
#
   my @CDList;
   my @DVDList;
   my @UpdatedFiles;
   my $index = 0;
   foreach $distroVersion (@distroVersions) {
#
      print p(sprintf(gettext("Doing %s"),$distroVersion));
#
      my ($distro,$version,$medium,$diskcount) = split /\|/, $distroVersion;
      my @Disks = @{$distroDisks[$index]};
#
#      foreach $iso (@Disks) {
#         print p("Iso=$iso");
#      }
#
      $index++;
      my $diskno = 0;
      foreach $disk (@Disks) {
         $diskno++;
         my $volume = "$distro-$version-${diskno}of$diskcount";
         my %diskHash =   (distro   =>	$distro,
                           version	=> $version,
                           medium	=> $medium,
                           total	   => $diskcount,
                           diskno	=> $diskno,
                           isoname	=> $disk);
#
#         print p("my \%diskHash = {distro=>$diskHash{'distro'},version=>$version,medium=>$medium,total=>$diskcount,diskno=>$diskno,isoname=>$disk};");
#
         ### Put all CDs in an array 
         if ($medium eq 'CD') {
               my %volumeHash = (Volume=>$volume, CD=>\%diskHash);
               push @CDList, \%volumeHash;  
         } else { ### Put all DVDs in an array and push onto DVDQueue
            my %volumeHash = (Volume=>$volume, DVD=>\%diskHash);
            push @DVDList, \%volumeHash;  
         }
      }
      ### List all the associated files for upgrading (xml, png etc)
      push @UpdatedFiles, $main::IsoDir.'/'.$distro.'/'.$distro.'.xml';
      push @UpdatedFiles, $main::ImageDir.'/'.$distro.'A.png';
      push @UpdatedFiles, $main::ImageDir.'/'.$distro.'B.png';
   }
   $cache->set('updatedFiles', \@UpdatedFiles);
   $cache->set('DVDList', \@DVDList);
   $cache->set('CDList', \@CDList);
   
   if ($burnMedium eq 'DVD') {
      putCDsIntoDVD('CDList', 'DVDList', $VolumeBaseName, 0);
   }
   sendListToQueue();

   #   Generate an update script, make into update ISO and add to CDQueue
   my @CDQueue = @{$cache->get('CDQueue')} if defined($cache->get('CDQueue'));
   my @DVDQueue = @{$cache->get('DVDQueue')} if defined($cache->get('DVDQueue'));
   my $updateISO = generateUpdateScript("$VolumeBaseName-Update", \@DVDQueue, \@CDQueue);
   my %Volume = (Volume=>$VolumeBaseName.'-Update', Path=>$updateISO);
   push @CDQueue, \%Volume;
   $cache->set('CDQueue', \@CDQueue);

   showBurnerQueues();
} # else task != burn

print $q->end_div;
print $q->end_html;
exit;
################################################################################
sub selectMedium() {
   print $q->h2(gettext("Choose what you want to burn onto:"));
   print $q->startform(-action=>$main::CGIURL.'/burn.pl');
   print $q->popup_menu('burnMedium', ['DVD', 'CD']);
   print $q->p(gettext("Volume base name (4 characters):"), $q->textfield('VolName', $VolumeBaseName,4,4));
   print $q->submit(-value=>gettext('Go'));
   print $q->endform;
}

sub generateUpdateScript {
   my ($VolumeID, $ARDVDQueue, $ARCDQueue) = @_;
   my @DVDQueue = @{$ARDVDQueue};
   my @CDQueue = @{$ARCDQueue};
   my $UpdateSnippet = "# update script generated from Freedom Toaster\n";

   foreach $DVDHash (@DVDQueue) {
      my %DVD = %{$DVDHash};
      my %DiskData = %{$DVD{'DVD'}};
      my @DiskArray = @{$DVD{'CDs'}};
      my $Volume = $DVD{'Volume'};
      $Volume =~ s/ +/ /g;
      $Volume =~ s/ $//;
      my $inputString = sprintf(gettext("Insert the DVD Labeled '%s' and press ENTER"),$Volume);
      $UpdateSnippet .= "VOLNAME=x\n". 
"JNK=x\n".
"until [ \"x\$VOLNAME\" = \"x$Volume\" -o x\$JNK = 'xskip' ]\n".
"do\n".
"   eject \$DVDDRIVES\n".
"   echo $inputString\n".
"   read JNK\n".
"   if [ ! x\$JNK = 'xskip' ]; then\n".
"      VOLNAME=".'$(volname $DVDDRIVES | tr -s \' \' | sed \'s/ $//\')'."\n".
"   fi\n".
"done\n".
"if [ ! x\$JNK = 'xskip' ]; then\n";

      if (@DiskArray) {
         $UpdateSnippet .= "   mount \$DVDDRIVES\n";
         foreach $Disk (@DiskArray) {
            my %DiskData = %{$Disk};
            my $CopySource = ' $DVDRWPATH/'.$DiskData{'isoname'}.' ';
            my $CopyDest = ' $ISODIR/'.
                              $DiskData{'distro'}."/".
                              $DiskData{'version'}."/".
                              $DiskData{'medium'}. "/"; 
            $UpdateSnippet .= "echo \"Copying $CopySource to $CopyDest\"\n";
            $UpdateSnippet .= "cp -uv $CopySource $CopyDest\n";
         }
      } else {
#CJPO: might need to do dd here...
#CJPO: decided to try readcd rather...
         $UpdateSnippet .= '   readcd -v dev=$DVDDRIVES f=$ISODIR/'.
                              $DiskData{'distro'}."/".
                              $DiskData{'version'}."/".
                              $DiskData{'medium'}."/". 
                              $DiskData{'isoname'}."\n"; 
      }
      $UpdateSnippet .= "fi\n";
   }
   foreach $CDHash (@CDQueue) {
      my %CD = %{$CDHash};
      my $Volume = $CD{'Volume'}.'A'; 
      my $inputString = sprintf(gettext("Insert the CD Labeled '%s' and press ENTER"),$Volume);
      $UpdateSnippet .= "JNK=x\n".
"until [ x\$VOLNAME = x$Volume -o x\$JNK = 'xskip' ]; do\n".
"   eject \$DVDDRIVES\n".
"   echo $inputString\n".
"   read JNK\n".
"   if [ ! x\$JNK = 'xskip' ]; then\n".
"      VOLNAME=\$(volname \$DVDDRIVES)\n".
"   fi\n".
"done\n".
"if [ ! x\$JNK = 'xskip' ]; then\n".
"   mount \$DVDDRIVES\n";
      if (defined($CD{'CD'})) {
         my %DiskData = %{$CD{'CD'}};
#CJPO: might need to do dd here...
#CJPO: decided to try readcd rather...
         $UpdateSnippet .= 'readcd -v dev=$DVDDRIVES f=$ISODIR/'.
                           $DiskData{'distro'}."/".
                           $DiskData{'version'}."/".
                           $DiskData{'medium'}. "/".
                           $DiskData{'isoname'}."\n"; 
      } elsif (defined($CD{'Path'})) {
         $UpdateSnippet .= 'echo "Copying $DVDRWPATH/'.$DiskData{'isoname'}.
                           ' to '.$CD{'Path'}."\"\n";
         $UpdateSnippet .= 'cp -uv $DVDRWPATH/'.
                           $DiskData{'isoname'}." ".
                           $CD{'Path'}."\n";
      }
      $UpdateSnippet .= "fi\n";
   }
   $UpdateSnippet .= "\nINSTALLVOLUME='$VolumeID'\n";
   $UpdateSnippet .= "\n# *************** Done **************** \n";

   my $Path = $main::CGIDir.'/upgrade';
   my $TWD = `mktemp -d /tmp/toaster.XXXXXX`;
   chomp($TWD);
   system "cp $Path/* $TWD";
   system "mv $TWD/Update.sh $TWD/InstallScript";
   system "chmod a+x $TWD/InstallScript $TWD/ContentUpdate";
   open(CUIN, "$TWD/ContentUpdate") or die "opening $TWD/ContentUpdate : $!";
   open(CUOUT,">$TWD/ContentUpdate2") or die "creating $TWD/ContentUpdate2 : $!";
   while (<CUIN>) {      # read a line from file $a into $_
      print CUOUT $_;    # print that line to file $b
      if (/###BURNTOP/) {
         print CUOUT "$UpdateSnippet";
      }
   }
   close(CUIN) or die "closing  $TWD/ContentUpdate: $!";
   close(CUOUT) or die "closing  $TWD/ContentUpdate2: $!";
   `cp $TWD/ContentUpdate2 $TWD/ContentUpdate`;
   open(MFIN,"$Path/MiscellaneousUpdates") or die "opening $Path/MiscellaneousUpdates : $!";
   my $MiscellaneousUpdates;
   while (<MFIN>) {
      chomp;
      $MiscellaneousUpdates .= "$_ ";
   }
   close MFIN;
# OK, here we do skullduggery to create a new isos tarball from the IsoDir (which may not be in root as I had assumed)
   `cd $main::IsoDir;tar -czf $TWD/NewDistros.tar.gz --exclude=*.iso --exclude=*.old --exclude=*tmp/* --exclude=*charles/* --exclude=lost+found ./`;
# What to do about Miscellaneous Updates and /images/? Create a tarball of NonCode updates in BaseDir
   `cd $main::BaseDir;tar -zpcf $TWD/NonCodeUpdates.tar.gz --exclude=.xvpics images/ --files-from=cgi-bin/upgrade/MiscellaneousUpdates`;

   my $NewVersion = `grep -m1 NEWVER $Path/config.inc | tr -d ' ' | cut -d'=' -f2`;

   $NewVersion =~ s/\s*//g;
   `cp $main::CGIDir/config.pl $main::CGIDir/config.pl.$NewVersion `;
   open(MGIN,"$Path/MiscellaneousUpgrades") or die "opening $Path/MiscellaneousUpgrades : $!";
   my $MiscellaneousUpgrades;
   while (<MGIN>) {
      chomp;
      $MiscellaneousUpgrades .= "$_ ";
   }
   close MGIN;
   my $NewVersionFile = "$TWD/toaster-$NewVersion.tar.gz";
   my $UpgradeFile = "$TWD/upgrade-$NewVersion.tar.gz";
   `cd $main::BaseDir;tar --exclude=config.pl --exclude=*.sw? --exclude=.xvpics -czf $NewVersionFile ./`;
   `cp $NewVersionFile $UpgradeFile`;
#   push @UpdatedFiles, ("$TWD/InstallScript", "$TWD/ContentUpdate", "$TWD/functions.inc", "$TWD/NewDistros.tar.gz");
#   push @UpdatedFiles, "$TWD/toaster-$NewVersion.tar.gz";
   push @UpdatedFiles, $MiscellaneousUpgrades;
   my $FileList = join(' ', @UpdatedFiles);
   `mkisofs -V $VolumeID -rJ -o $TWD/InstallCD.iso $TWD/* $FileList`;
   return "$TWD/InstallCD.iso";
}
