#!/usr/bin/perl

#########################################################################################
#											#
#	hrc_dose_conv_to_png.perl: convert full range HRC fits file to pgn images	#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Jul 19, 2005							#
#											#
#########################################################################################

$bin_dir = '/data/mta4/MTA/bin/';

$in_dir  = $ARGV[0];		# input directory name
$out_dir = $ARGV[1];		# output directory name
$year    = $ARGV[2];		# the year of the data obtained
$month   = $ARGV[3];		# the month of hte data obstained
chomp $in_dir;
chomp $out_dir;
chomp $year;
chomp $month;

if($month < 10){
	if($month !~ /^0/){
		$month = '0'."$month";
	}
}

$name = 'HRC*'."$month".'_'."$year".'*fits*';

$list = `ls $in_dir/$name`;
@in_list = split(/\s+/, $list);

system("mkdir Ftemp");
foreach $ent (@in_list){
	@atemp = split(/\//, $ent);
	$file  = pop (@atemp);
	@btemp = split(/fits/, $file);
	$out   = "$btemp[0]";
	$out   =~ s/\.//g;

#
#--- this is the actual script converts a fits image to a png image
#
	system("perl $bin_dir/mta_conv_fits_img.perl $ent ./Ftemp/$out log 125x125 heat png");
}
system("mv Ftemp/*png $out_dir/");
system("rm -rf Ftemp");
