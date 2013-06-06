#!/usr/bin/perl
################################################################################
#                               burnCCFiles.pl 
#                               ==============
# Purpose : Wizard to finding Creative Commons files on the toaster, and burning
#           them to CD/DVD.
# Input   : User search criteria via a wizard, such as:
#           - author(s) or any author,
#           - type(s) or any type (image, music, document etc)
#           - tag(s) or any tag
# Output  : The user is presented with a list of files from which to select the
#           one(s) s/he wants, then the option of finding more files or burning
#           the ones chosen so far.
#           For burning, the chosen files are converted to an iso
# License : GPL
# Author  : Charles Oertel (2006-05-20)
################################################################################
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
my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";

#my $admin = $cache->get('admin');
#if (!$admin) {
#   require("admin.pl");
#   exit;
#} 
################################################################################
# Control Variables: chooseType   - select File types for the search
#                    chooseAuthor - which authors', or all of them
#                    chooseLicense- which license restrictions if any...
#                    chooseTags   - which tags to search, or all of them
#                    chooseFiles  - select the files to burn from search results
#                    chooseNextStep - either go back to chooseType, or on to...
#                    burnDisk     - burn a CD of the chosen file list
#
# Notes: If we use a hash of filenames, and increment the value for every 
#        filename found under a tag, sorting the hash by value will give the
#        files in order of relevance (files in the most tags have highest value)
#
#        Search priority goes like this:
#        1) A given type and author is specified, then take all files in the
#           given tags provided they are also in the type and author.
#        2) If Type and/or Author is set to 'any', then take all files in the
#           given tags without caring whether they are in a specific Type and/or
#           Author.
#        3) If Tags are set to 'any' then either go through all the tags (good
#           because you can add up relevance), or go through the given author 
#           and/or Type.  Going through all the tags means you use the same
#           algorithm as for other cases...
################################################################################
#
$step = $cache->get('CCStep');

if ($q->param('next')) {
	if ($step eq 'chooseType') {
      my @selected = $q->param('FileTypes');
      $cache->set('CCFileTypes', \@selected);
      $cache->set('CCIgnoreFileTypes', $q->param('IgnoreFileType'));
	   $task = 'chooseAuthor';
	} elsif ($step eq 'chooseAuthor') {
      my @selected = $q->param('Authors');
      $cache->set('CCAuthors', \@selected);
      $cache->set('CCIgnoreAuthors', $q->param('IgnoreAuthor'));
	   $task = 'chooseLicense';
	} elsif ($step eq 'chooseLicense') {
      my @selected = $q->param('Licenses');
      $cache->set('CCLicenses', \@selected);
      $cache->set('CCIgnoreLicenses', $q->param('IgnoreLicense'));
		$task = 'chooseTags';
	} elsif ($step eq 'chooseTags') {
      my @selected = $q->param('Tags');
      $cache->set('CCTags', \@selected);
      $cache->set('CCAllTags', $q->param('AllTags'));
		$task = 'chooseFiles';
	} elsif ($step eq 'chooseFiles') {
      my @selected = $q->param('Files');
      $cache->set('CCFiles', \@selected);
		$task = 'chooseNextStep';
	} elsif ($step eq 'chooseNextStep') {
      if ($q->param('findMore')) {
         $task = 'chooseType';
      } elsif ($q->param('burnCD')) {
         $cache->set('CCBurnMedium', 'CD');
         $task = 'burnDisk'
      } elsif ($q->param('burnDVD')) {
         $cache->set('CCBurnMedium', 'DVD');
         $task = 'burnDisk'
      }
	} elsif ($step eq 'burnDisk') {
		$task = 'chooseNextStep';
   }
} elsif ($q->param('back')) {
	if ($step eq 'chooseAuthor') {
   	$task = 'chooseType';
	} elsif ($step eq 'chooseLicense') {
		$task = 'chooseAuthor';
	} elsif ($step eq 'chooseTags') {
		$task = 'chooseLicense';
	} elsif ($step eq 'chooseFiles') {
		$task = 'chooseTags';
	} elsif ($step eq 'burnDisk') {
		$task = 'chooseFiles';
   }
}

if ($step eq '') {
   $task = 'chooseType';
}

print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
print $q->start_html(-title=>gettext("Download Creative Commons files"), 
                     -encoding=>"UTF-8",
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL."/images/H_button.gif"})));
print $q->div({-id=>'MoreInfo'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/help/find_cc_files.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/K_button.gif'})));
if ($q->param('start'))	{ $backURL = "javascript:history.go(-1)"; }
else { $backURL=$main::CGIURL."/admin.pl?task=burnCCFiles&back=1"; }
print $q->div({-id=>'back'}, 
              $q->a({-href=>$backURL},
               $q->img({-name=>'back', -src=>$main::CSSURL."/images/L_button.gif"})));

################################################################################
# Display the screen
################################################################################
print $q->start_div({-id=>'content'});
print $q->img({ -src=>$main::HTMLURL.'/'.substr($lang,0,2).'/images/logoPage.png', -width=>"400", -height=>"131", -style=>"margin-left:170px"});
print $q->br();
print $q->h1(gettext("Burn Creative Commons Content"));

if ($task eq 'chooseType') {
	chooseType();
} elsif ($task eq 'chooseAuthor') {
	chooseAuthor();
} elsif ($task eq 'chooseLicense') {
	chooseLicense();
} elsif ($task eq 'chooseTags') {
	chooseTags();
} elsif ($task eq 'chooseFiles') {
   chooseFiles();
} elsif ($task eq 'chooseNextStep') {
   chooseNextStep();
} elsif ($task eq 'burnDisk') {
   burnDisk();
} 

print $q->end_div;
print $q->end_html;
exit;
################################################################################


sub chooseType() {
   $cache->set('CCStep', 'chooseType');
   my @selected = @{$cache->get('CCFileTypes')} if defined($cache->get('CCFileTypes'));

   print $q->p(gettext("Creative Commons licensing allows people to make their images, music or documents 
                        available to you to modify and/or use in various ways.  This set of screens will 
                        help you find such content and burn it to CD."));
   
   if (-d $main::IsoDir.'/CreativeCommons')	{
      print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
      print $q->hidden(-name=>"task", -value=>"burnCCFiles");
      print kiosk_list("FileTypes", gettext("Choose the Type of content you want"),
                     {'music'=>gettext('Music'),
                      'image'=>gettext('Image'),
                      'video'=>gettext('Video'),
                      'document'=>gettext('Document'),
                     },
                     \@selected, 1);

      my @IgnoreFileType = ($cache->get('CCIgnoreFileTypes')) if defined($cache->get('CCIgnoreFileTypes'));
      print kiosk_list("IgnoreFileType", "",
                     {'IgnoreFileType'=>gettext('Find any type of content')
                      },
                     \@IgnoreFileType, 0);

      print $q->div({-id=>'prevnext'}, $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png'));

      print $q->endform();
   } else {
      print $q->p(gettext("Sorry, there's no Creative Commons content available for burning on this Toaster."));
   }
}

sub chooseAuthor() {
   $cache->set('CCStep', 'chooseAuthor');
   my @selected = @{$cache->get('CCAuthors')} if defined($cache->get('CCAuthors'));
   my %Authors = %{kiosk_GetCCMetaDirs($main::IsoDir.'/CreativeCommons/MetaData/Authors')};

   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"burnCCFiles");
   print kiosk_list("Authors", gettext("Choose which authors' work you are interested in"),
                     \%Authors,
                     \@selected, 1);

   my @IgnoreAuthor = ($cache->get('CCIgnoreAuthors')) if defined($cache->get('CCIgnoreAuthors'));
   print kiosk_list("IgnoreAuthor", "",
                     {'IgnoreAuthor'=>gettext('From any Author')
                      },
                     \@IgnoreAuthor, 0);

   print $q->div({-id=>'prevnext'}, $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png'),
                                    $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png'));

   print $q->endform();
}

sub chooseLicense() {
   $cache->set('CCStep', 'chooseLicense');
   my @selected = @{$cache->get('CCLicenses')} if defined($cache->get('CCLicenses'));
   my %Licenses = %{kiosk_GetCCMetaDirs($main::IsoDir.'/CreativeCommons/MetaData/Licenses')};

   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"burnCCFiles");
   print kiosk_list("Licenses", gettext("Choose which licenses would be acceptible to you"),
                     \%Licenses,
                     \@selected, 1);

   my @IgnoreLicense = ($cache->get('CCIgnoreLicenses')) if defined($cache->get('CCIgnoreLicenses'));
   print kiosk_list("IgnoreLicense", "",
                     {'IgnoreLicense'=>gettext('Under any License')
                      },
                     \@IgnoreLicense, 0);

   print $q->div({-id=>'prevnext'}, $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png'),
                                    $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png'));

   print $q->endform();
}

sub chooseTags() {
   $cache->set('CCStep', 'chooseTags');
   my @selected = @{$cache->get('CCTags')} if defined($cache->get('CCTags'));
   my %Tags = %{kiosk_GetCCMetaDirs($main::IsoDir.'/CreativeCommons/MetaData/Tags')};

   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"burnCCFiles");
   print kiosk_list("Tags", gettext("Choose the tags to search for"),
                     \%Tags,
                     \@selected, 1);

   my @AllTags = ($cache->get('CCAllTags')) if defined($cache->get('CCAllTags'));
   print kiosk_list("AllTags", "",
                     {'AllTags'=>gettext('Search for all tags')
                      },
                     \@AllTags, 0);

   print $q->div({-id=>'prevnext'}, $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png'),
                                    $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png'));

   print $q->endform();
}

sub chooseFiles() {
   $cache->set('CCStep', 'chooseFiles');
   my @selected = @{$cache->get('CCFiles')} if defined($cache->get('CCFiles'));
   my $ContentPath = $main::IsoDir.'/CreativeCommons/Content/';
   my $IgnoreFileTypes = $cache->get('CCIgnoreFileTypes');
   my $IgnoreAuthors = $cache->get('CCIgnoreAuthors');
   my $IgnoreLicenses = $cache->get('CCIgnoreLicenses');
   my $AllTags = $cache->get('CCAllTags');
   my @SelectedFileTypes;
   my @SelectedAuthors = @{$cache->get('CCAuthors')} if defined($cache->get('CCAuthors'));
   my @SelectedLicenses = @{$cache->get('CCLicenses')} if defined($cache->get('CCLicenses'));
   my @SelectedTags;
   my %FileList, %FileCount;

   if ($AllTags) {
      my %Tags = %{kiosk_GetCCMetaDirs($main::IsoDir.'/CreativeCommons/MetaData/Tags')};
      @SelectedTags = keys %Tags;
   } else {
      @SelectedTags = @{$cache->get('CCTags')} if defined($cache->get('CCTags'));
   }
   if ($IgnoreFileTypes) { # search through all types
      my %FileTypes = %{kiosk_GetCCMetaDirs($main::IsoDir.'/CreativeCommons/Content')};
      @SelectedFileTypes = keys %FileTypes;
   } else {
      @SelectedFileTypes = @{$cache->get('CCFileTypes')} if defined($cache->get('CCFileTypes'));
   }

   foreach $tag (@SelectedTags) {
     my $TagPath = $main::IsoDir."/CreativeCommons/MetaData/Tags/$tag/"; 
     opendir(DIR, $TagPath) or die "opening directory $TagPath : $!";
     for (readdir(DIR)) {
        next if (/^\./);
        my $Name = $_;
        my $DirPath = $TagPath.'/'.$Name;
### Here we filter results based on search criteria...
        foreach $FileType (@SelectedFileTypes) {
           my $FileTypePath = $main::IsoDir."/CreativeCommons/Content/$FileType/$Name"; 
           if (-f $FileTypePath) {  # file exists as type
### For each identified file of type, only store it if Author, and License match...
              my $AuthorMatches = 0;
              my $LicenseMatches = 0;
              if ($IgnoreAuthors) {
                 $AuthorMatches = 1;
              } else {
                  foreach $Author (@SelectedAuthors) {
                     my $AuthorPath = $main::IsoDir."/CreativeCommons/MetaData/Authors/$Author/$Name"; 
                     if (-f $AuthorPath) {  # file exists as author
                        $AuthorMatches = 1;
                        last;
                     }
                  }
              }
              next if (!$AuthorMatches);
              if ($IgnoreLicenses) {
                 $LicenseMatches = 1;
              } else {
                  foreach $License (@SelectedLicenses) {
                     my $LicensePath = $main::IsoDir."/CreativeCommons/MetaData/Licenses/$License/$Name"; 
                     if (-f $LicensePath) {  # file exists as license
                        $LicenseMatches = 1;
                        last;
                     }
                  }
              }
              next if (!$LicenseMatches);
              $FileList{"$Name ($FileType)"} = $FileTypePath;
              $FileCount{"$Name ($FileType)"} += 1;
           }
        }
      }
      closedir(DIR);
   }
   my %DisplayList;
   my %ValidFilePaths;
   if (defined($cache->get("CCValidFilePaths"))) {
      %ValidFilePaths = %{$cache->get("CCValidFilePaths")};
   }
   foreach $item (keys %FileList) {
      $DisplayList{$item} = $item;
      $ValidFilePaths{$item} = $FileList{$item};
   }
   $cache->set('CCValidFilePaths',\%ValidFilePaths);

   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"burnCCFiles");
   print kiosk_list("Files", gettext("Choose the files you want to burn"),
                     \%DisplayList,
                     \@selected, 1);
   print $q->div({-id=>'prevnext'}, $q->image_button(-name=>'back', -value=>"1", -src=>$ImageURL.'/back.png'),
                                    $q->image_button(-name=>'next', -value=>"1", -src=>$ImageURL.'/next.png'));

   print $q->endform();
}

sub chooseNextStep() {
   $cache->set('CCStep', 'chooseNextStep');
   my @selected = @{$cache->get('CCFiles')} if defined($cache->get('CCFiles'));
   my $FileCount = @selected;

   print $q->start_multipart_form(-action=>$main::CGIURL.'/admin.pl');
   print $q->hidden(-name=>"task", -value=>"burnCCFiles");
   print $q->hidden(-name=>"next", -value=>"1");
   print $q->h2(sprintf(ngettext("You have selected %d file", "You have selected %d files",$FileCount), $FileCount));

   print $q->div({-id=>'prevnext'}, $q->br(),$q->br(),
												$q->image_button(-name=>'burnCD', -value=>"1", -src=>$ImageURL.'/burncd.png'),
												$q->br(),$q->br(),
												$q->image_button(-name=>'burnDVD', -value=>"1", -src=>$ImageURL.'/burndvd.png'),
												$q->br(),$q->br(),
												$q->image_button(-name=>'findMore', -value=>"1", -src=>$ImageURL.'/findmore.png'));

   print $q->endform();
}

sub burnDisk() {
   $cache->set('CCStep', 'burnDisk');
   my @selected = @{$cache->get('CCFiles')} if defined($cache->get('CCFiles'));
   my $Medium = $cache->get('CCBurnMedium');
   my %ValidFilePaths = %{$cache->get("CCValidFilePaths")};
   my @ContentFiles;

   foreach $filekey (@selected) {
      my $path = $ValidFilePaths{$filekey};
      $path =~ s/^.*Content\///;
      $path =~ s/^(.*\/)(.*)$/$1'$2'/;
      push @ContentFiles, $path;
   }
   my $ContentFiles = join(' ', @ContentFiles);
   my $ContentDir = $main::IsoDir.'/CreativeCommons/Content';

   print $q->h2(sprintf(gettext("Preparing your %s iso for toasting"), $Medium));

   ################################################################################
   # Here we have an issue of concurrency:  we create an iso file, but while
   # we are waiting for it to burn (maybe queues are long), somebody else selects
   # some files to burn and overwrites the iso file with other stuff.  Not good.
   # 
   # So, we see whether our filename is more than a day old.  If it is, we reuse it.
   # It it isn't, we increment the number and test to see if it exists.  If it 
   # exists, then reuse it if it is more than a day old, otherwise, increment again.
   # We should end up with the ContentDisk.iso name being reused every day, and if
   # more than one disk is burnt in a day, ContentDisk0001 to ContentDisk9999.iso
   # are available, with the highest number indicating the most isos ever burned
   # in a day.
   ################################################################################
   my $IsoFileName = 'ContentDisk0001.iso';
   my $NameBusy = 1;
   my $FileCount = 1;
   $^T = time;  #refresh script time...

   while ($NameBusy) {
      if (-e "$ContentDir/$IsoFileName") {
         stat("$ContentDir/$IsoFileName");
         if ( -M "$ContentDir/$IsoFileName" ge 1.0 ) {
            $NameBusy = 0;
         } else {
            $FileCount++;
            $IsoFileName = sprintf("ContentDisk%04d.iso", $FileCount);
         }
      } else { # filename available to use, so exit...
         $NameBusy = 0;
      }
   }
   `cd $ContentDir;mkisofs -rJ -o $IsoFileName $ContentFiles`;
   my %Volume = (Volume=>"CCContent$FileCount", Path=>"$ContentDir/$IsoFileName");

   if ($Medium eq 'CD') {
      my @CDQueue = @{$cache->get('CDQueue')} if defined($cache->get('CDQueue'));
      push @CDQueue, \%Volume;
      $cache->set('CDQueue', \@CDQueue);
   } else {
      my @DVDQueue = @{$cache->get('DVDQueue')} if defined($cache->get('DVDQueue'));
      push @DVDQueue, \%Volume;
      $cache->set('DVDQueue', \@DVDQueue);
   }
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

   print $q->div({-id=>'prevnext'}, $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
												$q->img({-src=>$ImageURL.'/next.png'})));

}

sub kiosk_list() {
################################################################################
# Purpose : Draw a scrolling list with large text and proper clickable
#           labels that can be used on a touch screen...
# Input   : $name     - the cgi variable name
#           $question - the description or question the user is answering
#           %labels   - reference to item labels keyed by associated values
#           @defaults - the selected values (keys in %labels)
#           $multi    - true to allow multiple selections (checkboxes)
#                       false for single selection only (radio-buttons)
# Output  : a text string containing the markup for this item, in a div
# Remarks : This is a modification of the CGI::scrolling_list method
# Created : Charles Oertel (2006/05/20) - charles@finebushpeople.net
# License : GPL
################################################################################
   my ($name, $question, $labelref, $defaultref, $multi) = @_;
   my $return;
   my %labels = %{$labelref};
   my @values = sort keys %labels;
   my @defaults = @{$defaultref};
   my $type = ($multi) ? 'checkbox' : ($#values) ? 'radio' : 'checkbox';

	my $count = @values;  # how many, 'cos < 4 means make div smaller...
	my $divheight = ($count < 4) ? 48*$count + 6 : 168;

# build a little lookup hash to notice checked values...
   my %checked;
   foreach $value (@defaults) {
      $checked{$value} += 1;
   }

   $return = '<div style="text-align:left;vertical-align:top;margin:1em;font-size:130%;">'."\n";
   $return .= "<p><strong>$question:</strong></p>\n" if ($question ne '');
   $return .= '<div style="height:'.$divheight.'px;overflow:auto;">'."\n";
   $return .= '<table border="0" cellpadding="5">'."\n";
   foreach $value (@values) {
      my $checked = 'checked="checked"' if ($checked{$value});
      $return .= "<tr>\n";
      $return .= "   <td><input type=\"$type\" name=\"$name\" value=\"$value\" id=\"$value\" $checked /></td>\n";
      $return .= "   <td><label for=\"$value\">".$labels{$value}."</label></td>\n";
      $return .= "</tr>\n";
   }
   $return .= "</table>\n";
   $return .= "</div>\n";
   $return .= "</div>\n";

   return($return);
}

sub kiosk_GetCCMetaDirs() {
################################################################################
# Purpose : Find all the populated directories in a given parent directory so
#           that you can make a selection list of it.  For example, all the
#           authors in MetaData/Authors
# Input   : $path - the full path to the category you want to enumerate, for
#                   e.g. /srv/isos/CreativeCommons/MetaData/Authors
#                   (This allows you to use it to enumerate other paths too,
#                   like all the items in MetaData etc...
# Output  : Returns a reference to a hash of the form
#           return{'charles'} = 'charles';
# Created : Charles Oertel (2006/05/20) - charles@finebushpeople.net
# License : GPL
################################################################################
   my ($path) = @_;
   my %return;

   opendir(DIR, $path) or die "opening directory $path : $!";
   for (readdir(DIR)) {
      next if (/^\./);
      my $Name = $_;
      my $DirPath = $path.'/'.$Name;
      $return{$Name} = $Name if (-d $DirPath);
   }
   closedir(DIR);
   return(\%return);
}
