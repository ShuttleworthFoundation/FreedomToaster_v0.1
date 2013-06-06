#!/usr/bin/perl
###!/usr/bin/perl -w
#use strict;
use CGI qw(:all);
require ("config.pl");
use Cache::FileCache;
use POSIX;
use Locale::gettext;
use Digest::MD5 qw(md5_base64);

my $q = new CGI;
my $task = $q->param('task');
my $lang = $q->cookie(-name=>'FTlang');
setLocaleParms($lang);

my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Cant create file cache";

my $admin = $cache->get('admin');

if ($admin) {
   require("admin.pl");
   exit;
} elsif ($q->param('adminPassword')) {
   if (md5_base64($q->param('adminPassword')) eq $main::AdminPass) {
	   $cache->set('admin', 1);
	   require("admin.pl");
	   exit;
   } else {
      sleep 5;
      print $q->redirect({URL=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'});
      exit;
   }
}

   

print $q->header(-type=>'text/html', -charset=>'UTF-8', -encoding=>"UTF-8");

print $q->start_html(-title=>"Admin Login", 
				-encoding=>"UTF-8",
                     -style=>{'src'=>$main::CSSURL."/kiosk.css"},
	                  -background=>$main::CSSURL."/images/selectorBG.png",
                     -head=>meta({-http_equiv =>'refresh', -content => '90; URL="'.$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html"'}));
print $q->div({-id=>'Home'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2).'/index0.html'},
               $q->img({-name=>'home', -src=>$main::CSSURL.'/images/H_button.gif'})));
print $q->div({-id=>'back'}, 
              $q->a({-href=>$main::HTMLURL.'/'.substr($lang,0,2)."/index0.html"},
               $q->img({-name=>'back', -src=>$main::CSSURL.'/images/L_button.gif'})));

################################################################################
# Present an onscreen keyboard and prompt for password
################################################################################
print $q->start_div({-id=>'content'});
print $q->h1("$task:");


print $q->startform({name=>'adminForm'});
print $q->p(gettext("Enter the administrator password using the keyboard below:"));
print $q->password_field({name=>"adminPassword",value=>''});

print $q->start_table({-cellspacing=>'10'});

my $colCount=0;

foreach $letter qw(1 2 3 4 5 6 7 8 9 0 q w e r t y u i o p a s d f g h j k l . . z x c v b n m .) {
   my $ClickJS = "document.adminForm.adminPassword.value+='$letter'";
   if (!$colCount%10) {
      print $q->start_Tr;
   }
   $colCount+=1;
   print $q->td($q->button(-class=>'key', -name=>$letter, -value=>$letter, -onClick=>$ClickJS));
   if (!($colCount%10)) {
      print $q->end_Tr;
   }
}
if ($colCount%10) {
   print $q->end_Tr;
}
print $q->end_table;
print $q->submit({name=>'Enter'});
print $q->end_form;

print $q->end_div;
print $q->end_html;
