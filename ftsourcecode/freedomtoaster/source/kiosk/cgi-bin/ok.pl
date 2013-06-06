#!/usr/bin/perl -w #Create initial feedback page
use CGI ':standard';
use Cache::FileCache;
use POSIX;
use Locale::gettext;

require("config.pl");

my $q = new CGI;
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);

my $distroVersion = $q->param('distroVersion');
my ($distro, $version, $medium, $count) = split /\|/, $distroVersion;
my $ToastDefault = $q->param('ToastDefault');
my $DoItNow = $q->param('DoItNow');
my $Advanced = $q->param('Advanced');
my $cache=new Cache::FileCache({-namespace => 'newKiosk'});

if ($ToastDefault or $DoItNow) {
   my @distroVersion = @{$cache->get('distroVersion')} if defined($cache->get('distroVersion'));
   push @distroVersion, $distroVersion;
   $cache->set('distroVersion', \@distroVersion);
   my @distroDisks = @{$cache->get('distroDisks')} if defined($cache->get('distroDisks'));
   push @distroDisks, &getImages();
   $cache->set('distroDisks', \@distroDisks);
   if ($Advanced) {
      print $q->redirect({URL=>"showQueue.pl?task=ShowAdvanced"}); 
   } else {
      sendDistrosTo('Queue'); # send them away for immediate burning...
      print $q->redirect({URL=>"showQueue.pl"}); 
   }
   exit;
} elsif ($Advanced) {
   print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");
   print $q->start_html(-title => gettext("Advanced Burning Options"),
   		-encoding=>"UTF-8",
            -style=>{'src' => [ $main::CSSURL."/kiosk.css" ] },
            -background =>$main::CSSURL."/images/selectorBG.png",
            -script=>{-language=>'javascript', -src=>$main::BaseURL.'/kiosk.js'},
            -head=>meta({-http_equiv =>'refresh', -content => '90; URL="'.$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html"'}));
   print $q->start_div({-id=>'content'});      
   print $q->div({-id=>'MoreInfo'}, 
               $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/help/advanced_burning_options.html'},
                  $q->img({-name=>'home', -src=>$main::CSSURL.'/images/K_button.gif'})));
   print $q->div({-id=>'Home'}, 
               $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
                  $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
   print $q->div({-id=>'back'}, 
               $q->a({-href=>'javascript:history.go(-1)'},
                  $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));
   
   my ($Versions,$RadioValues,$RadioLabels,$DefaultVersion) = distroVersions($distro);
   printVersionSelect($Versions,$RadioValues,$RadioLabels,$DefaultVersion,0);

   print $q->end_div;
   print $q->end_html;
}

sub getImages () {
	my @discs;
	opendir (DIR, "$main::IsoDir/$distro/$version/$medium") or die ("Cannot open the directory: $main::IsoDir/$distro/$version/$medium\n");
	while ( defined ( my $file = readdir(DIR) ) ) {
		next if $file =~ /^\./;
		next if $file !~ /\.iso$/;
		push(@discs,$file);
	}
	closedir(DIR);
	my @sortdiscs = sort @discs;
	return \@sortdiscs;
}

