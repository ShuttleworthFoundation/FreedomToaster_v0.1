#!/usr/bin/perl -w
use strict;
use CGI  qw(:all);
use Cache::FileCache;
require("config.pl");

my $cache=new Cache::FileCache({-namespace => 'newKiosk'}) or die "Can't create file cache in newKiosk namespace";
my @resource = keys %main::Devices;         # concurrent resources

my $q = new CGI;
# Now get on and cut those CD's
# Clear some /tmp files to reset status from last burn
my $burner;
foreach $burner (@resource) {
   if (($cache->get("toasting.$burner")) or
       ($cache->get("blanking.$burner")) or
       ($cache->get("prompting.$burner"))) {
      next;
   }
	`sudo cdrecord dev=$main::Devices{$burner} -load`;
}
print $q->redirect($main::BaseURL.'/index.html');
exit;

