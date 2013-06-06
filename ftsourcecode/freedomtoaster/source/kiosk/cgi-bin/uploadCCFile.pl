#!/usr/bin/perl
################################################################################
#                               uploadCCFile.pl 
#                               ===============
# Purpose : Wizard to walk through selecting, tagging and saving a Creative
#           Commons content file.
# Input   : The content on CD or DVD that is inserted into a CDROM drive
#           User selection to choose the file from the CD, tags, author, etc.
# Output  : The file is copied from the CD to the hard-drive, and tags are
#           saved in a directory of meta-data so that the file can be retrieved.
# License : GPL
# Author  : Charles Oertel (2006-05-14)
################################################################################
###!/usr/bin/perl -w
#use strict;
use CGI qw(:all);
require ("config.pl");
use Cache::FileCache;
use POSIX;
use Locale::gettext;

my $q = new CGI;
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);
my $ImageURL = "../locale/".substr($lang,0,2)."/images";

my $task = $q->param('task');
my $uploadFile = $q->param('uploadFile');
my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";

my $admin = $cache->get('admin');

if (!$admin) {
   require("admin.pl");
   exit;
} 
################################################################################
# Control Variables: insertCD   - open drive and prompt for user to insert CD
#                    selectFile - present a list of files found on the CD and
#                                 prompt the user to select one
#                    fileType   - get type, license and author info
#                    selecttags - choose and create search and classification tags
#                    confirm    - display chosen values and have the user confirm
################################################################################
#
$device = $cache->get('CCDevice');
$step = $cache->get('CCStep');
if ($uploadFile=~/\S/) { #cgi param set so update cache
   $cache->set('CCUploadFile', $uploadFile);
   $task = 'fileType';
   $step = 'fileType';
} elsif ($cache->get('CCUploadFile')=~/\S/) {
      $uploadFile = $cache->get('CCUploadFile');
}
if ($q->param('next')) {
   if ($step eq 'insertCD') {
      $task = 'selectFile';
   } elsif ($step eq 'selectFile') {
      $task = 'fileType';
   } elsif ($step eq 'fileType') {
      $cache->set('CCFileType', $q->param('FileType'));
      $task = 'authorName';
   } elsif ($step eq 'authorName') {
      $cache->set('CCAuthorName', $q->param('AuthorName'));
      $task = 'confirmOwnership';
   } elsif ($step eq 'confirmOwnership') {
      if ($q->param('field_ownership') eq 'y') {
         $task = 'licenseType';
      } else {
         $task = 'confirmOwnership';
      }
   } elsif ($step eq 'licenseType') {
      $cache->set('CCCommercial', $q->param('field_commercial'));
      $cache->set('CCDerivatives', $q->param('field_derivatives'));
      my $License = 'Creative Commons 2.5 with Attribution';
      if ($q->param('field_commercial') eq 'n') {
         $License .= ' NonCommercial';
      }
      if ($q->param('field_derivatives') eq 'n') {
         $License .= ' NoDerivatives';
      } elsif ($q->param('field_derivatives') eq 'sa') {
         $License .= ' ShareAlike';
      }
      $cache->set('CCLicense', $License);
      $task = 'selectTags';
   } elsif ($step eq 'addTags') {
      CreateTag($q->param('NewTag'));
      my @SelectedTags;
      if (defined($cache->get('CCSelectedTags'))) {
         @SelectedTags = @{$cache->get('CCSelectedTags')};
      }
      push @SelectedTags,$q->param('NewTag');
      $cache->set('CCSelectedTags', \@SelectedTags);
      $task = 'selectTags';
   } elsif ($step eq 'selectTags') {
      my @selected = $q->param('AvailableTags');
      $cache->set('CCSelectedTags',\@selected);
      $task = 'confirm';
   } elsif ($step eq 'confirm') {
      $task = 'save';
   } elsif ($step eq 'save') {
      $task = 'home';
   }
} elsif ($q->param('back')) {
   if ($step eq 'selectFile') {
      system("umount $device") if ($device ne '');
      $task = 'insertCD';
   } elsif ($step eq 'fileType') {
      $task = 'selectFile';
   } elsif ($step eq 'authorName') {
      $task = 'fileType';
   } elsif ($step eq 'confirmOwnership') {
      $task = 'authorName';
   } elsif ($step eq 'licenseType') {
      $task = 'confirmOwnership';
   } elsif ($step eq 'addTags') {
      $task = 'selectTags';
   } elsif ($step eq 'selectTags') {
      $task = 'licenseType';
   } elsif ($step eq 'confirm') {
      $task = 'selectTags';
   }
} elsif ($step eq 'selectFile') {
   $task = 'selectFile';
} elsif ($q->param('addTags')) {
   my @selected = $q->param('AvailableTags');
   $cache->set('CCSelectedTags',\@selected);
   $task = 'addTags';
} elsif ($step eq 'selectTags') {
   $task = 'selectTags';
}

if ($step eq '') {
   system("umount $device") if ($device ne '');
   $task = 'insertCD';
}


print $q->header;

print $q->start_html(-title=>gettext("Upload CC Content"), 
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL."/images/H_button.gif"})));
print $q->div({-id=>'MoreInfo'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/help/find_cc_files.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/K_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::CGIURL."/admin.pl?task=uploadCCFile&back=1"},
               $q->img({-name=>'back', -src=>$main::CSSURL."/images/L_button.gif"})));

################################################################################
# Display the screen
################################################################################
print $q->start_div({-id=>'admin'});
print $q->h1(gettext("Upload Creative Commons Content"));

#print $q->p("task = $task");
#print $q->p("CCDevice=", $cache->get('CCDevice'));
#print $q->p("CCStep=$step.", $cache->get('CCStep'));
#print $q->p("uploadFile=", $uploadFile,'.');
#print $q->p("authorName=", $cache->get('CCAuthorName'));
#print $q->p("next=", defined($q->param('next')));
#print $q->p("back=", defined($q->param('back')));

if ($task eq 'insertCD') {
   insertCD();
} elsif ($task eq 'selectFile') {
   selectFile();
} elsif ($task eq 'fileType') {
   fileType($uploadFile);
} elsif ($task eq 'authorName') {
   authorName();
} elsif ($task eq 'confirmOwnership') {
   confirmOwnership();
} elsif ($task eq 'licenseType') {
   licenseType();
} elsif ($task eq 'selectTags') {
   selectTags();
} elsif ($task eq 'addTags') {
   addTags();
} elsif ($task eq 'confirm') {
   confirm();
} elsif ($task eq 'save') {
   save();
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
   print $q->hidden(-name=>'task', -value=>'uploadCCFile');
   print $q->h3(gettext("Insert your CD/DVD in the open CDROM drive then click 'Next'"));
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png', -align=>'center');
   print $q->endform();
   $cache->set('CCDevice', $device);
   $cache->set('CCStep', 'insertCD');
}

sub selectFile() {
   my $uploadFile = '';
   $cache->set('CCStep', 'selectFile');
   print $q->h2(gettext("Selecting Files from the CD"));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");
   my $cdpath = $cache->get('CCMountPath');
   my $mounted = `mount | grep -c $device`;
   if ($mounted==0) {
      if (system('mount '.$device.' 2>/dev/null 1>&2') ne 0) {
         print $q->p(sprintf(gettext("Unable to mount %s. Aborting"),$device));
         exit;
      } 
   }
   $cdpath = getMountPath($device);
   $cache->set('CCMountPath', $cdpath);
   if (defined($q->param('goIntoDir'))) {
      $cdpath = $q->param('goIntoDir');
   } 

   if ($uploadFile eq '') { # search for it until found...
      print '<div style="text-align:left;margin:1em auto;padding:1em;border:1px solid black;background:white;width:50%;height:300px;overflow:auto">';
      opendir(DIR, $cdpath) or die "opening directory $cdpath : $!";
      for (readdir(DIR)) {
         next if (/^\./);
         my $currentFileName = "$_";
         my $currentFile = "$cdpath/$currentFileName";
         # ok, if $currentFile is a directory, allow the user to expand it...
         if (-d $currentFile) {
            print $q->p($q->image_button(-name=>'goIntoDir', -value=>"$currentFile", -src=>$main::ImageURL.'/folder.png', -align=>'center'), $q->image_button(-name=>'goIntoDir', -value=>"$currentFile", -src=>$ImageURL.'/nothing.png', -alt=>"$currentFileName"));
         } else {
            print $q->p($q->image_button(-name=>'uploadFile', -value=>"$currentFile", -src=>$main::ImageURL.'/file.png', -align=>'center'), $q->image_button(-name=>'uploadFile', -value=>"$currentFile", -src=>$ImageURL.'/nothing.png', -alt=>"$currentFileName"));
         }
      }
      close(DIR);
      print '</div>';
   }
   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png', -align=>'center');
   print $q->endform();
   exit;
}

sub fileType() {
   my ($fileName) = @_;
   $cache->set('CCStep', 'fileType');
   my $MountPath = $cache->get('CCMountPath');
   $fileName=~s/^$MountPath//;  # strip off the /media/cdrom0 stuff for display...
   my $selected = $cache->get('CCFileType');
   my ($music, $image, $document, $video) = (($selected eq 'music') ? 'checked="checked"' : '',
                                     ($selected eq 'image') ? 'checked="checked"' : '',
                                     ($selected eq 'video') ? 'checked="checked"' : '',
                                     ($selected eq 'document') ? 'checked="checked"' : '');
   print $q->h2(gettext("Choose the right values for your file"));
   print $q->h3(sprintf(gettext("Info about %s"),$fileName));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");
   print kiosk_radio("FileType", gettext("Type of data in the file"),
                     {'music'=>gettext('Music'), 'image'=>gettext('Image'), 'document'=>gettext('Document'), 'video'=>gettext('Video')}, $selected);

   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png');
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png');

   print $q->endform();
   exit;
}

sub authorName() {
   $cache->set('CCStep', 'authorName');
   print $q->h2(gettext("Author Name"));
   print $q->h3(gettext("Enter your Name then press Next >"));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");
   print KeyboardEntryField("AuthorName");
   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png');
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png');

   print $q->endform();
   exit;
}

sub confirmOwnership() {
   $cache->set('CCStep', 'confirmOwnership');
   print $q->h2(gettext("Confirm Ownership of this File"));
   print $q->h3(gettext("You may only upload works to which you own the copyright"));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");
   print kiosk_radio('field_ownership', gettext("Does this file contain your own original work?"),
                     { 'y'=>gettext('Yes'), 'n' =>gettext('No') }, 'n');
   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png');
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png');

   print $q->endform();
   exit;
}

sub licenseType() {
   $cache->set('CCStep', 'licenseType');
   my $commercialdefault = (defined($cache->get('CCCommercial'))) ? $cache->get('CCCommercial') : 'y';
   my $derivativesdefault = (defined($cache->get('CCDerivatives'))) ? $cache->get('CCDerivatives') : 'y';
   print $q->h2(gettext("Creative Commons License Type"));
   print $q->h3(gettext("Choose the license most suitable to your desired use of this file, then press Next >"));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");

   print kiosk_radio('field_commercial', gettext("Allow commercial uses of your work?"),
                     { 'y'=>gettext('Yes'), 'n' =>gettext('No') }, $commercialdefault);
   print kiosk_radio('field_derivatives', gettext("Allow modification of your work?"),
                     { 'y'=>gettext('Yes'), 'sa'=>gettext('provided the license stays the same as this one (share alike)'), 'n' =>gettext('No') }, $derivativesdefault);

   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png');
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png');

   print $q->endform();
   exit;
}

sub selectTags() {
   $cache->set('CCStep', 'selectTags');
   my @SelectedTags = @{$cache->get('CCSelectedTags')} if defined ($cache->get('CCSelectedTags'));
   ### Build up list of available tags from directories in meta/tags
   if (! -d $main::IsoDir.'/CreativeCommons/MetaData/Tags') {
      if (! -d $main::IsoDir.'/CreativeCommons/MetaData') {
         if (! -d $main::IsoDir.'/CreativeCommons') {
            system('mkdir '.$main::IsoDir.'/CreativeCommons');
         }
         system('mkdir '.$main::IsoDir.'/CreativeCommons/MetaData');
      }
      system('mkdir '.$main::IsoDir.'/CreativeCommons/MetaData/Tags');
   }
   my $TagDirectory = $main::IsoDir.'/CreativeCommons/MetaData/Tags'; 

   my @AvailableTags;

   opendir(DIR, $TagDirectory) or die "opening directory $TagDirectory : $!";
   for (readdir(DIR)) {
      next if (/^\./);
      my $TagName = $_;
      my $DirPath = $TagDirectory.'/'.$TagName;
      push @AvailableTags,$TagName if (-d $DirPath);
   }
   closedir(DIR);

   print $q->h2(gettext("Tag Your File"));
   print $q->h3(gettext("Choose the tags that describe your file, then press Next >"));
   print $q->h3(gettext("If you need to add a different tag to the list, press '+ add new tag'."));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");

   print <<'END_TEXT';
<script>
var arrOldValues;

function FillListValues(CONTROL){
   var arrNewValues;
   var intNewPos;
   var strTemp = GetSelectValues(CONTROL);
   arrNewValues = strTemp.split(",");
   for(var i=0;i<arrNewValues.length-1;i++){
      if(arrNewValues[i]==1){
         intNewPos = i;
      }
   }

   for(var i=0;i<arrOldValues.length-1;i++){
      if(arrOldValues[i]==1 && i != intNewPos){
         CONTROL.options[i].selected= true;
      }
      else if(arrOldValues[i]==0 && i != intNewPos){
         CONTROL.options[i].selected= false;
      }

      if(arrOldValues[intNewPos]== 1){
         CONTROL.options[intNewPos].selected = false;
      }
      else{
         CONTROL.options[intNewPos].selected = true;
      }
   }
}


function GetSelectValues(CONTROL){
   var strTemp = "";
   for(var i = 0;i < CONTROL.length;i++){
      if(CONTROL.options[i].selected == true){
         strTemp += "1,";
      }
      else{
         strTemp += "0,";
      }
   }
   return strTemp;
}

function GetCurrentListValues(CONTROL){
   var strValues = "";
   strValues = GetSelectValues(CONTROL);
   arrOldValues = strValues.split(",")
}
</script>
END_TEXT
   my @sortedTags = sort(@AvailableTags);

   print $q->scrolling_list( -name=>"AvailableTags",
                             -values=>\@sortedTags,
                             -default=>\@SelectedTags,
                             -size=>10,
                             -multiple=>'true',
                             -onmousedown=>"GetCurrentListValues(this);",
                             -onchange=>"FillListValues(this);",
                             -style=>"font-size:150%;margin:5em;border:1px solid red");
   print $q->br();
   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png');
   print $q->image_button(-name=>'addTags', -value=>"1", -src=>$ImageURL.'/addtags.png');
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png');

   print $q->endform();
   exit;
}

sub addTags() {
   $cache->set('CCStep', 'addTags');
   print $q->h2(gettext("Add New Tags"));
   print $q->h3(gettext("Enter the tag you want to create, then press Next >"));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");
   print KeyboardEntryField("NewTag");
   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png');
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png');
   print $q->endform();
   exit;
}

sub CreateTag() {
   my ($newTag) = @_;
   my $TagDirectory = $main::IsoDir.'/CreativeCommons/MetaData/Tags'; 
   if ($newTag=~/\S/) {
      system("mkdir $TagDirectory/$newTag");
   }
}

sub confirm() {
   $cache->set('CCStep', 'confirm');
   print $q->h2(gettext("Confirmation"));
   print $q->h3(gettext("If you are happy with the settings shown below, press Next >"));
   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"uploadCCFile");

   my $FileName = $cache->get('CCUploadFile');
   $FileName=~s#^.*/##;

   print $q->table({-style=>"text-align:left",
                    -cellpadding=>5,
                    -caption=>gettext("Confirm Values to be saved")},
                   Tr([
                      th([gettext('Setting'), gettext('Value')]),
                      td([strong(gettext('File Name:')), $FileName]),
                      td([strong(gettext('File Type:')), $cache->get('CCFileType')]),
                      td([strong(gettext('Author Name:')), $cache->get('CCAuthorName')]),
                      td([strong(gettext('License:')), $cache->get('CCLicense')]),
                      td([strong(gettext('Tags:')), join(' ', @{$cache->get('CCSelectedTags')})])
                      ]));

   print $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png');
   print $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png');
   print $q->endform();
   exit;
}

sub save() {
   $cache->set('CCStep', 'save');
   if (! -d "'".$main::IsoDir."/CreativeCommons/Content/".$cache->get('CCFileType')."'") {
      if (! -d $main::IsoDir.'/CreativeCommons/Content') {
         if (! -d $main::IsoDir.'/CreativeCommons') {
            system('mkdir '.$main::IsoDir.'/CreativeCommons');
         }
         system('mkdir '.$main::IsoDir.'/CreativeCommons/Content');
      }
      system("mkdir '".$main::IsoDir."/CreativeCommons/Content/".$cache->get('CCFileType')."'");
   }
   my $DestinationDirectory = "'".$main::IsoDir."/CreativeCommons/Content/".$cache->get('CCFileType')."'"; 
   print $q->h2(gettext("Saving File onto the Freedom Toaster"));

   my $FileName = "'".$cache->get('CCUploadFile')."'";
   system("cp $FileName $DestinationDirectory"); # or die("Unable to copy content $FileName to $DestinationDirectory: $!");
   $FileName =~ s#^.*/##;  # strip path leaving only the bit after the last '/'
   $NewFileName = "'".$DestinationDirectory.'/'.$FileName; # quote still lurking at back
   # $FileName still has a ' (quote) at the end of it, but not in front.  Fine, work with it...

   if (! -d $main::IsoDir.'/CreativeCommons/MetaData/Authors') {
      if (! -d $main::IsoDir.'/CreativeCommons/MetaData') {
         system('mkdir '.$main::IsoDir.'/CreativeCommons/MetaData');
      }
      system('mkdir '.$main::IsoDir.'/CreativeCommons/MetaData/Authors');
   }
   if (! -d "'".$main::IsoDir."/CreativeCommons/MetaData/Authors/".$cache->get('CCAuthorName')."'") {
      system("mkdir '".$main::IsoDir."/CreativeCommons/MetaData/Authors/".$cache->get('CCAuthorName')."'");
   }
   system("ln $NewFileName '".$main::IsoDir."/CreativeCommons/MetaData/Authors/".$cache->get('CCAuthorName')."/$FileName");

   if (! -d $main::IsoDir.'/CreativeCommons/MetaData/Licenses') {
      system('mkdir '.$main::IsoDir.'/CreativeCommons/MetaData/Licenses');
   }
   if (! -d "'".$main::IsoDir."/CreativeCommons/MetaData/Licenses/".$cache->get('CCLicense')."'") {
      system("mkdir '".$main::IsoDir."/CreativeCommons/MetaData/Licenses/".$cache->get("CCLicense")."'");
   }
   system("ln $NewFileName '".$main::IsoDir."/CreativeCommons/MetaData/Licenses/".$cache->get("CCLicense")."/$FileName");

   if (! -d $main::IsoDir.'/CreativeCommons/MetaData/Tags') {
      system('mkdir '.$main::IsoDir.'/CreativeCommons/MetaData/Tags');
   }
   foreach $tag (@{$cache->get('CCSelectedTags')}) {
      if (! -d $main::IsoDir."/CreativeCommons/MetaData/Tags/$tag") {
         system("mkdir ".$main::IsoDir."/CreativeCommons/MetaData/Licenses/$tag");
      }
      system("ln $NewFileName '".$main::IsoDir."/CreativeCommons/MetaData/Tags/$tag/$FileName");
   }

   print $q->h3(gettext("Your file was successfully saved"));
   print $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
         $q->img({-src=>$ImageURL.'/next.png'}));
   system("umount ".$cache->get('CCDevice'));
   system("eject ".$cache->get('CCDevice'));
   $cache->remove('CCStep');
   $cache->remove('CCDevice');
   $cache->remove('CCMountPath');
   $cache->remove('CCUploadFile');
   $cache->remove('CCFileType');
   $cache->remove('CCAuthorName');
   $cache->remove('CCCommercial');
   $cache->remove('CCDerivatives');
   $cache->remove('CCLicense');
   $cache->remove('CCSelectedTags');
   exit;
}

sub kiosk_radio() {
################################################################################
# Purpose : Draw a radio button group with large text and proper clickable
#           labels that can be used on a touch screen...
# Input   : $name     - the radio button group name
#           $question - the description or question the user is answering
#           %labels   - reference to labels keyed by associated values
#           $default  - the selected value (key)
# Output  : a text string containing the markup for this item, in a div
# Remarks : This is a modification of the CGI::radio_group method
# Created : Charles Oertel (2006/05/18) - charles@finebushpeople.net
# License : GPL
################################################################################
   my ($name, $question, $labelref, $default) = @_;
   my $return;
   my %labels = %{$labelref};
   my @values = keys %labels;

   $return = '<div style="text-align:left;vertical-align:top;padding-left:4em;font-size:150%;">'."\n";
   $return .= "<p><strong>$question:</strong></p>\n";
   $return .= '<table border="0" cellpadding="5" style="margin:10px 10px 40px 200px;float:left">'."\n";
   foreach $value (@values) {
      my $checked = 'checked="checked"' if ($value eq $default);
      $return .= "<tr>\n";
      $return .= "   <td><input type=\"radio\" name=\"$name\" value=\"$value\" id=\"$value\" $checked /></td>\n";
      $return .= "   <td><label for=\"$value\">".$labels{$value}."</label></td>\n";
      $return .= "</tr>\n";
   }
   $return .= "</table><br clear=\"all\" />\n";
   $return .= '</div>';
   return($return);
}
