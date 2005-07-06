#!/usr/bin/perl

#########################################################################
#									#
#   hrc_does_update_html.perl: update date on full_hrc_exposure_map.html#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	Last update : Jul 6, 2005					#
#									#
#########################################################################

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
$year  = 1900   + $uyear;
$month = $umon  + 1;

$line = "<br><br><H3> Last Update: $month/$umday/$year</H3>";

open(FH, '/data/mta_www/mta_max_exp/HRC/full_hrc_exposure_map.html');

@save = ();
while(<FH>){
	chomp $_;
	push(@save, $_);
}
close(FH);

open(OUT, '>/data/mta_www/mta_max_exp/HRC/full_hrc_exposure_map.html');

foreach $ent (@save){
	if($ent =~ /Last Update/){
		print OUT "$line\n";
	}else{
		print OUT "$ent\n";
	}
}
close(OUT);
