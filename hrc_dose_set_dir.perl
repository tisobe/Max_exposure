#!/usr/bin/perl

#########################################################################################
#                                                                                       #
#       hrc_dose_set_dir.perl: setting directries needed for hrc dose computation	#
#                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                       #
#       last update: Aug 18, 2005                                                       #
#                                                                                       #
#########################################################################################

###############################################################################
#---- set directories

$bin_dir  = '/data/mta/MTA/bin/';
$dat_dir  = '/data/mta/MTA/data/';
$mon_dir  = '/data/mta/www/mta_max_exp/Month_hrc/';
$cum_dir  = '/data/mta/www/mta_max_exp/Cumulative_hrc/';
$data_out = '/data/mta/www/mta_max_exp/Data/';
$plot_dir = '/data/mta/www/mta_max_exp/Plots/';
$img_dir  = '/data/mta/www/mta_max_exp/Images';
$web_dir  = '/data/mta/www/mta_max_exp/';

$lookup   = '/home/ascds/DS.release/data/dmmerge_header_lookup.txt';    # dmmerge header rule lookup table

###############################################################################

#
#--- print out a directory list so that other scripts can read it.
#
open(OUT, '>./dir_list');

print OUT "$bin_dir\n";
print OUT "$dat_dir\n";
print OUT "$mon_dir\n";
print OUT "$cum_dir\n";
print OUT "$data_out\n";
print OUT "$plot_dir\n";
print OUT "$img_dir\n";
print OUT "$web_dir\n";
print OUT "$lookup\n";

close(OUT)

