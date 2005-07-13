#!/usr/bin/perl

#################################################################################
#										#
#	ps2gif.perl: change a ps file to gif file				#
#										#
#		this script work only from rhodes				#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#										#
#	last update: Jul 12, 2005						#
#										#
#################################################################################

$in_file  = $ARGV[0];
$out_plot = $ARGV[1];
chomp $in_file;
chomp $out_plot; 

$bin_dir  = "/data/mta4/MTA/bin/";

system("/opt/local/bin/ds9 $in_file -zoom to fit -scale histequ -cmap Heat -saveimage png $out_plot  -lower -iconify -exit");

