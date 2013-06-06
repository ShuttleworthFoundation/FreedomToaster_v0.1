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
my $ImageURL = "../locale/".substr($lang,0,2)."/images";

my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";
my $Advanced = 0;
$Advanced = $cache->get('ShowAdvanced') if defined($cache->get('ShowAdvanced'));
my $HelpPage = $main::HTMLURL.'/'.substr($lang,0,2).'/help/show_queue.html';
my $URL = $main::CGIURL.'/showQueue.pl';
if (!countQueueSize()) {
	$URL = $main::HTMLURL.'/'.substr($lang,0,2).'/index0.html';
}

print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
print $q->start_html(-title=>"Toast your Selection", 
				-encoding=>"UTF-8",
				-style=>{'src'=>$main::CSSURL."/kiosk.css"},
                     -script=>{-language=>'javascript', -src=>$main::BaseURL.'/kiosk.js'},
                     -head=>meta({-http_equiv =>'refresh', -content => "20; URL=$URL"}),
	                  -background=>$main::CSSURL."/images/selectorBG.png");
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>"javascript:history.go(-1)"},
               $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));

sendDistrosTo('List');
if ($task=~/ClearQueue/) {
   clearList();
} elsif ($task=~/ToastAll/) {
   putCDsIntoDVD('CD2DVDList', 'DVDList', 'MyCDsOnDVD', 0);
   sendListToQueue();
} elsif ($task=~/AddCDtoDVD/) {
   moveCDIso('CDList', $q->param('selectedIndex'), 'CD2DVDList');
} elsif ($task=~/RemCDfromDVD/) {
   moveCDIso('CD2DVDList', $q->param('selectedIndex'), 'CDList');
} elsif ($task=~/ShowAdvanced/) {
   $cache->set('ShowAdvanced', 1);
   $Advanced = 1;
} elsif ($task=~/HideAdvanced/) {
   $cache->set('ShowAdvanced', 0);
   $Advanced = 0;
} elsif ($task=~/ClearCDList/) {
   $cache->remove('CDList');
} elsif ($task=~/ClearDVDList/) {
   $cache->remove('DVDList');
} elsif ($task=~/ClearCD2DVDList/) {
   $cache->remove('CD2DVDList');
} elsif ($task=~/ClearCDQueue/) {
   $cache->remove('CDQueue');
} elsif ($task=~/ClearDVDQueue/) {
   $cache->remove('DVDQueue');
}

my $showArrow = 'showQueueNoSelection';
my $shoppingCartCount = shoppingCartCount();
if (!$shoppingCartCount) { # there are items in the selections, display arrow...
   $showArrow = 'showQueueNoSelection';
   $Advanced = 0; # no items, no need to be advanced...
   $cache->set('ShowAdvanced', 0);
}

if ($Advanced) {
   $HelpPage = $main::HTMLURL.'/'.substr($lang,0,2).'/help/advanced_queue_options.html';
}

print $q->div({-id=>'MoreInfo'}, 
              $q->a({-href=>$HelpPage},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/K_button.gif'})));

################################################################################
# Display the screen
################################################################################
print $q->start_div({-id=>'content', -style=>'margin:0 30px 0 100px'});
print $q->start_div({-id=>$showArrow});
print $q->h1(gettext("Toast your Selection"));

if ($Advanced or $shoppingCartCount) {
   showIsoLists($Advanced);
   print $q->br({-clear=>"left"});
   showListControls($q, $Advanced, $shoppingCartCount);
   print $q->br({-clear=>"left"});
} else {
   print $q->br();
   print $q->p(gettext("The burners are shown on the left - when one is ready to toast your CD it will open the disk caddy and show buttons for you to choose an action.  The buttons you are likely to see are:"), br(),br(),
               strong(gettext("Toast:")), " ", gettext("click this when you have inserted your blank disk into the caddy to tell the toaster that it can start toasting that disk"),br(),br(),
               strong(gettext("Skip:")), " ", gettext("click this if you no longer want to burn that item"),br(),br(),
               strong(gettext("Retry:")), " ", gettext("if there is a failure, you can choose to retry the burn"),br(),br(),
               strong(gettext("Done:")), " ", gettext("choose this if you have taken out your toasted disk and have noted what was burned onto it"),br(),br(),
               strong(gettext("Blank:")), " ", gettext("on some rewritable media, if the initial burn fails because the disk was not empty, you get the option to blank the disk and to retry")
              );
   print $q->p(gettext("The queues below show items waiting for a CD burner to become available.  As burners become available, queued items are automatically sent to them.  'Clear List' deletes the items on the queue."));
}
print $q->br({-clear=>"left"});
showBurnerQueues();

print $q->end_div;
print $q->end_div;
print $q->end_html;
exit;
################################################################################

sub showListControls {
################################################################################
# Purpose : Display the 'Toast Now' and 'Advanced >' buttons under the right
#           conditions
# Input   : $q        - the display object
#           $Advanced - is the advanced screen showing?
#           $selected - are there items to send to the burners?
# Output  : Displays the right buttons.
#            - if there are items selected, displays 'Toast All'
#              - if not Advanced, show the 'Show Advanced' button
#            - if Advanced, show 'Hide Advanced'
# Created : Charles Oertel (2006/02/18)
# License : GPL and CC with attribution
################################################################################
   my ($q, $Advanced, $selected) = @_;

   my ($ToastButton, $ToggleButton);

   if ($selected) {
      $ToastButton = $q->image_button(-name=>"Toast All", -title=>gettext("Send all the selected CDs, DVDs and "), -style=>"position:absolute;bottom:270px;right:280px", -src=>$ImageURL."/toast_selection.png", -onclick=>"document.ListForm.task.value='ToastAll';document.ListForm.submit();");

      $ToggleButton = $q->image_button(-name=>"Show Advanced Options", -title=>gettext("Show Advanced Options"), -style=>"position:absolute;top:370px;right:70px", -src=>$ImageURL."/advanced.png", -onclick=>"document.ListForm.task.value='ShowAdvanced';document.ListForm.submit();");
   } else {
      print $q->p(sprintf(gettext("There are no items selected for toasting.  Use the %s button on the top left of this screen to view the home page, where you will be able to choose which software you want to toast to disk."), $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'}, gettext('home'))));
   }

   if ($Advanced) {
      $ToggleButton = $q->image_button(-name=>"Hide Advanced Options", -title=>gettext("Hide Advanced Options"), -style=>"position:absolute;top:370px;right:70px", -src=>$ImageURL."/hide_advanced.png", -onclick=>"document.ListForm.task.value='HideAdvanced';document.ListForm.submit();");
   }

   print $q->div({-id=>"ListControls"},
                  $ToastButton,
#                  $ToggleButton
                );
}

sub moveCDIso {
################################################################################
# Purpose: Move an iso from the SourceList to the DestinationList
# Input  : SourceList      - the place where the CD iso is
#          selectedIndex   - the index of the item in the Source list
#          DestinationList - the list to put the item onto
#          Cache::FileCache with CDList, DVDList and CD2DVDList 
# Output : Cache::FileCache with Source and Destination updated to show the move
# Created: Charles Oertel, copyright 2006/02/05
# License: GPL and Creative Commons with attribution
################################################################################
   my ($SourceList, $selectedIndex, $DestinationList) = @_;
   $selectedIndex = 0 if ($selectedIndex < 0);
   my @SourceList = @{$cache->get($SourceList)} if defined($cache->get($SourceList));
   my @DestinationList = @{$cache->get($DestinationList)} if defined($cache->get($DestinationList));
   my @movedItems = splice @SourceList, $selectedIndex, 1;
   push @DestinationList, @movedItems;
   $cache->set($DestinationList, \@DestinationList);
   $cache->set($SourceList, \@SourceList);
}
