#!/usr/bin/perl
###!/usr/bin/perl -w 
use CGI qw(:all);
require("config.pl");
use POSIX;
use Locale::gettext;
use Encode qw/decode/;

$|=1;
my $q=new CGI;

my $distro = $q->param('distro');
my $task   = $q->param('task');
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);

print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
print $q->start_html(-title => gettext("Selection of a Distro"),
			-encoding=>"UTF-8",
			-style=>{'src' => [ "$main::CSSURL/kiosk.css" ] },
			-background =>"$main::CSSURL/images/selectorBG.png",
         -script=>{-language=>'javascript', -src=>$main::BaseURL.'/kiosk.js'},
         -head=>meta({-http_equiv =>'refresh', -content => '90; URL="'.$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html"'}));
print $q->start_div({-id=>'content'});      
print $q->img({ -src=>$main::HTMLURL.'/'.substr($lang,0,2).'/images/logoPage.png', -width=>"400", -height=>"131", -style=>"margin-left:170px"});
print $q->br();
print $q->div({-id=>'MoreInfo'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/help/distro_burning.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/K_button.gif'})));
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>'javascript:history.go(-1)'},
               $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));


my ($Versions,$RadioValues,$RadioLabels,$DefaultVersion) = distroVersions($distro);
distroInfo();
if (@{$RadioValues} > 0)	{
   print $q->h2(decode("utf8",gettext("Latest Version")));
   printVersionSelect($Versions,$RadioValues,$RadioLabels,$DefaultVersion,1);
} else {
   print $q->h2(decode("utf8",gettext("Sorry, no version found on this kiosk")));
}
print $q->end_div;
print $q->end_html;


sub distroInfo {
   use XML::Simple;
   $xml = new XML::Simple(KeyAttr=>[]);
   my $lang = getCurrentLang(1);
   my $distroInfo;
   if ( -e "$main::IsoDir/$distro/$distro-$lang.xml" ) 	{
   	$distroInfo = $xml->XMLin("$main::IsoDir/$distro/$distro-$lang.xml");
   } else {
   	$distroInfo = $xml->XMLin("$main::IsoDir/$distro/$distro.xml");
   }
   binmode(STDOUT,":utf8");
   print $q->img({-src=>'../images/'.$distro.'B.png', -style=>'margin-top:25px', -align=>'left'});
   print $q->h1({-class=>'infoHead'}, decode("utf8",gettext("You are about to toast ")), $distroInfo->{name}, $q->div({-style=>'font-size:small'}, "(",$distroInfo->{description},")"));
   print $q->h2(decode("utf8",gettext("Advantages")));
   print $q->ul($q->li({-class=>'distInfo'}, $distroInfo->{advantages}{advantage}));

   print $q->h2(decode("utf8",gettext("Disadvantages")));
   print $q->ul($q->li({-class=>'distInfo'}, $distroInfo->{disadvantages}{disadvantage})); 
}
