#!/usr/bin/perl

#################################################################################
#										#
#	ps2png.perl: change a ps file to png file				#
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
chomp $in_file;
chomp $out_plot; 

if($in_file eq '' || $out_plot eq '' || $in_file =~ /-h/i){
	print "Usage: perl ps2png.perl <ps image> <output png image name>\n";
	exit 1;
}

$bin_dir  = "/data/mta4/MTA/bin/";

system("/opt/local/bin/ds9 $in_file -zoom to fit -scale histequ -cmap Heat -saveimage png $out_plot  -lower -iconify -exit");

