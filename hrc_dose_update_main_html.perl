#!/usr/bin/perl

$bin_dir  = '/data/mta4/MTA/bin/';                      # this works only from rhodes
$dat_dir  = '/data/mta4/MTA/data/';
$web_dir  = '/data/mta/www/mta_max_exp/';


#
#--- get today's date
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

$year   = 1900   + $uyear;
$month  = $umon  + 1;

$new_line = '<br><br><H3> Last Update: '."$month/$umday/$year".'</H3>';

open(FH,"$web_dir/exposure.html");
open(OUT, "> ./temp");
while(<FH>){
	chomp $_;
	if($_ =~ /Last Update/){
		print OUT "$new_line\n";
	}else{
		print OUT "$_\n";
	}
}
close(OUT);
close(FH); 
system("mv ./temp $web_dir/exposure.html");

open(FH,"$web_dir/HRC/full_hrc_exposure_map.html");
open(OUT, "> ./temp");
while(<FH>){
	chomp $_;
	if($_ =~ /Last Update/){
		print OUT "$new_line\n";
	}else{
		print OUT "$_\n";
	}
}
close(OUT);
close(FH); 
system("mv ./temp $web_dir/HRC/full_hrc_exposure_map.html");
