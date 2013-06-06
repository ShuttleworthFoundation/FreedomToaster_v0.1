#!/usr/bin/perl
###!/usr/bin/perl -w
#use strict;
use CGI qw(:all);
require ("config.pl");
use POSIX;
use Locale::gettext;

my $q = new CGI;
my $list = $q->param('list');
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);

$list='all' if (!defined($list));


print $q->header;

print $q->start_html(-title=>gettext("Choose Something to Toast"), 
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png",
                     -script=>{-language=>'javascript', -src=>$main::BaseURL.'/kiosk.js'},
                     -head=>meta({-http_equiv =>'refresh', -content => '90; URL="'.$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html"'}));
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>'javascript:history.go(-1)'},
               $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));

################################################################################
# Now we read in a list of items to present and put them in a grid with 
# pretty pictures etc gleaned from their directory in the /iso/ location
################################################################################
print $q->start_div({-id=>'content'});
print $q->h1(gettext("Click the pictures:"));

print $q->start_table({-cellspacing=>'10'});

use XML::Simple;
my $xml = new XML::Simple(KeyAttr=>[]);
my $ItemList = $xml->XMLin("$main::IsoDir/$list.xml"); 
my $colCount=0;

foreach $Item (@{$ItemList->{items}{path}}) {
   if (!$colCount%3) {
      print $q->start_Tr;
   }
   $colCount+=1;
   my $ImgTagID = $Item.'ID';
   my $ImageFileA = "$main::IsoDir/$Item/Images/$Item"."A.png";
   my $ImageFileB = "$main::IsoDir/$Item/Images/$Item"."B.png";
   $ImageFileA = "$main::ImageURL/$Item"."A.png";
   $ImageFileB = "$main::ImageURL/$Item"."B.png";
   my $MouseOut  = "$ImgTagID.src='$ImageFileB'";
   my $MouseOver = "$ImgTagID.src='$ImageFileA'";
   print $q->td(
                $q->a({-href=>$main::CGIURL."/distro.pl?distro=$Item",
                       -onMouseOver=>$MouseOver, -onMouseOut=>$MouseOut},
                         $q->img({-name=>"$ImgTagID",-src=>$ImageFileB,-width=>'231',-height=>'71'})
                         )
                );
   if (!($colCount%3)) {
      print $q->end_Tr;
   }
}
if ($colCount%3) {
   print $q->end_Tr;
}
print $q->end_table;

print $q->end_div;
print $q->end_html;
