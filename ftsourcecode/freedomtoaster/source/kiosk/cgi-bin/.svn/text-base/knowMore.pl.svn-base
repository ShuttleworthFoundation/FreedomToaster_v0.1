#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
use Cache::FileCache;
require ("config.pl");
use POSIX;
use Locale::gettext;
use XML::LibXML; 
   
#main program
my $currentPlace;
my $cache=new Cache::FileCache ({-namespace => 'knowMore'}) or die "Cant create file cache";

if ( defined ($currentPlace = $cache->get('currentPlace') ) ) {
	# get the next line from the knowMore.xml file
	$currentPlace++;
} else {
	# Then this is the start of the Find-out-more session
	$currentPlace=0;
}
$cache->set('currentPlace',$currentPlace);

my $saying = getSayingXML($currentPlace);
if ( $saying eq 0 ) {
	# We have come to the end of this knowMore stuff, so we must return
	# to the main cutLinux page
	gen_finishsplash();
	$cache->remove('currentPlace');
} else {
	# We have more information to bombard on the user
	my $didUKnow=getDiduknowXML();
	gen_anothersplash($saying, $didUKnow);
}

exit 0;


sub gen_finishsplash {
	my $q = new CGI;
	my $lang = $q->cookie(-name=>'FTlang');
	setLocaleParms($lang);
	
	my $homeLink = $main::HTMLURL.'/'.substr($lang,0,2).'/index0.html';
	print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
	print $q->start_html(-title=>gettext("The End of More Info"),
                     -encoding=>"UTF-8",
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
                     -background=>$main::CSSURL."/images/selectorBG.png",
                     -script=>{-language=>'javascript', -src=>$main::BaseURL.'/kiosk.js'},
                     -head=>meta({-http_equiv =>'refresh', -content => '90; URL='.$homeLink}));
   print $q->start_div({-id => 'help'});
   print $q->div({-id=>'Home'}, 
               $q->a({-href=>$homeLink},
                  $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
   print $q->div({-id=>'back'}, 
               $q->a({-href=>'javascript:history.go(-1)'},
                  $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));
	print<<"BUTTONS";
	<div id="next">	
		<a href="$homeLink" onmouseup="r_button.src=\'$main::ImageURL/r_top_release.png\'" onmousedown="r_button.src=\'$main::ImageURL/r_top_push.png\'"><img name='next' src="$main::CSSURL/images/R_button.gif"></a>
	</div>
BUTTONS

        print $q->img({-src=>$main::HTMLURL.'/'.substr($lang,0,2).'/images/logoHelp.png', -width=>"305", -height=>"100", -align=>"right", -style=>"margin:-10px -60px 0 0"});
	print $q->h1(gettext("Credits"));
	print $q->p(gettext("We hope this has encouraged you to try some of our Open Source and Creative Commons Items"));
   print $q->img({-src=>$main::ImageURL.'/shuttleworth.png',-align=>'right',-alt=>gettext('The Shuttleworth Foundation initiated, sponsored and manages these Freedom Toasters'), -style=>'margin-left:10px'});
	print $q->h2(gettext("Concept:"));
   print $q->p(gettext("These guys had the idea of this kiosk and spent money on finding the right PC to do the job, and developing the right software.  This is an example of what they call \"creating a global phenomenon\""));
   print $q->p(gettext("Now this Freedom Toaster is in demand in developing nations on several continents, and the know-how and software is available to anybody who wants to do something similar."));
   print $q->img({-src=>$main::ImageURL.'/fbp.png', -align=>'right'});
	print $q->h2(gettext("Development:"));
	print $q->p(gettext("The chap involved here is a physicist who loves to experiment and invent.  He also builds websites and is an experienced programmer.  We knew him as a volunteer helping install computer labs in schools."));
   print $q->p({-style=>'text-align:center'}, "Charles Oertel", br(), 'Tel: (021) 701 8231', br(), 'Email: Charles@FineBushPeople.net');
	print $q->end_div;
	print $q->end_html;
}

sub gen_anothersplash {
	my ($saying, $info) = @_;
	my $q = new CGI;
	my $lang = $q->cookie(-name=>'FTlang');
	setLocaleParms($lang);
	my $ImageURL = "../locale/".substr($lang,0,2)."/images";
	my $csscode = <<ENDCSS;
div#PopupBox {
   background : transparent URL($ImageURL/did_you_know.png) bottom left no-repeat;
   position : absolute;
   left     : 320px;
   top      : 700px;
   width : 185px;
   height : 38px;
   margin : 0 auto;
   padding : 0;
}
div#PUBInner {
   background : transparent URL($ImageURL/did_you_know_open2.png) top left;
   margin : 0;
   display : none;
   height : 185px;
   width  : 185px;
   font-size : small;
   color:black;
}
div#PopupBox:hover {
   height : 185px;
   width  : 185px;
   top    : 538px;
}

div#PopupBox:hover div#PUBInner {
   display : block;
}

div#PUBInner h2  {
 padding : 10px;
 margin-bottom : 0;
 color:#FFF; 
 text-align:center;
 font-size : small;
}

div#PUBInner p  {
 padding : 5px 8px;
 margin  : 0;
}
ENDCSS
	
	print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
	print $q->start_html(-title => gettext("Find out more"),
	-encoding=>"UTF-8",
	-style=>{-'src'=>$main::CSSURL."/kiosk.css", -verbatim =>"$csscode"},
	-background=>$main::CSSURL."/images/selectorBG.png",
   -script=>{-language=>'javascript', -src=>$main::BaseURL.'/kiosk.js'},
	-head=>meta({-http_equiv =>'refresh', -content => '60; URL='.$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'}));
   print $q->start_div({-id => 'help'});
   print $q->div({-id=>'Home'}, 
               $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
                  $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
   print $q->div({-id=>'back'}, 
               $q->a({-href=>'javascript:history.go(-1)'},
                  $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));
	print<<"BUTTONS";
	<div id="next">	
		<a href='$main::CGIURL/knowMore.pl'  onmouseup="r_button.src=\'$main::ImageURL/r_top_release.png\' "onmousedown="r_button.src=\'$main::ImageURL/r_top_push.png\'"><img name='next'  src="$main::CSSURL/images/R_button.gif"></a>
	</div>
BUTTONS
	binmode(STDOUT,":utf8");
        print $q->img({-src=>$main::HTMLURL.'/'.substr($lang,0,2).'/images/logoHelp.png', -width=>"305", -height=>"100", -align=>"right", -style=>"margin:-10px -60px 0 0"});
	print $q->h1($saying->getElementsByTagName('title')->item(0)->textContent),
		$q->start_ul,
		$q->li({-class=>'newL'},$saying->getElementsByTagName('subtitle1')->item(0)->textContent),
		$q->span({-class=>'txtMoreInfoL'},$saying->getElementsByTagName('content1')->item(0)->toString);
	print ("<br>&nbsp<br/>");
	print $q->li({-class=>'newR'},$saying->getElementsByTagName('subtitle2')->item(0)->textContent),
		$q->span({-class=>'txtMoreInfoR'},$saying->getElementsByTagName('content2')->item(0)->toString),
		$q->end_ul;
	print $q->div({-id=>'PopupBox'},
                      $q->div({-id=>'PUBInner'},
                      $q->h2($info->getElementsByTagName('title')->item(0)->textContent),
                      $q->p($info->getElementsByTagName('content')->item(0)->toString)));
                       
	print $q->end_div;
	print $q->end_html;
}

sub getSayingXML {
   my $saying_number = $_[0];
   my $q = new CGI; # just for retrieving lang cookie
   my $lang = $q->cookie(-name=>'FTlang');

   my $xml = XML::LibXML->new();
   my $data = $xml->parse_file($main::HTMLDir.'/'.substr($lang,0,2).'/sayings/knowMore.xml');
   my $root = $data->getDocumentElement;
   my @sayings  = $root->getElementsByTagName('saying');
   my $sayingsNum = @sayings;
   if ( $saying_number >= $sayingsNum )	{ return 0; }
   else   { return $sayings[$saying_number]; }
}

sub getDiduknowXML {
   my $q = new CGI; # just for retrieving lang cookie
   my $lang = $q->cookie(-name=>'FTlang');
   my $xml = XML::LibXML->new();
   my $data = $xml->parse_file($main::HTMLDir.'/'.substr($lang,0,2).'/sayings/did_u_know.xml');
   my $root = $data->getDocumentElement;
   my @infos  = $root->getElementsByTagName('info');
   return $infos[int(rand(@infos))];
}
