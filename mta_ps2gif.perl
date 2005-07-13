#!/usr/bin/perl

#################################################################################
#										#
#	ps2gif.perl: change a ps file to gif file				#
#										#
#		this script work only from rhodes				#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#										#
#	last update: Jul 13, 2005						#
#										#
#################################################################################

$in_file  = $ARGV[0];
$out_plot = $ARGV[1];
$img_size = $ARGV[2];
chomp $in_file;
chomp $out_plot; 
chomp $img_size;
if($in_file eq '' || $out_plot eq '' || $in_file =~ /-h/i){
	print "Usage: perl mta_ps2gif.perl <input ps image> <out put gif name> <image size eg. 256x256>\n";
	exit 1;
}
if($img_size eq ''){
	$img_size = '256x256';
}

$bin_dir  = "/data/mta4/MTA/bin/";

system("/opt/local/bin/ds9 $in_file -zoom to fit -scale histequ -cmap Heat -print destination file -print filename foo.ps -print -lower -iconify -exit");

system("echo ''|gs -sDEVICE=ppmraw  -r$img_size -q -NOPAUSE -sOutputFile=-  ./foo.ps|$bin_dir/pnmcrop|$bin_dir/ppmtogif > $out_plot");

#
#----- if you need to rotate a figure,  add " $bin_dir/pnmflip -r270 " or an appropriate angle in the line above
#

system("rm foo.ps");

