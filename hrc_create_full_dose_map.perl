#!/usr/bin/perl

#########################################################################################
#											#
#	hrc_create_full_dose_map.perl: a master script to create full HRC dose maps	#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Jul 21, 2005							#
#											#
#########################################################################################

$bin_dir  = '/data/mta4/MTA/bin/';			# this works only from rhodes
$dat_dir  = '/data/mta4/MTA/data/';
$mon_dir  = '/data/mta/Script/Exposure/Hrc/Month_hrc/';
$cum_dir  = '/data/mta/Script/Exposure/Hrc/Cumulative_hrc/';
$data_out = '/data/mta/www/mta_max_exp/HRC/Data/';
$plot_dir = '/data/mta/www/mta_max_exp/HRC/Plots/';
$mays_dir = '/data/mays/MTA/Exposure/Hrc/';

$usr = `cat $dat_dir/.dare`;
$pass = `cat $dat_dir/.hakama`;
chomp $usr;
chomp $pass;

#
#--- get today's date
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

$year   = 1900   + $uyear;
$month  = $umon  + 1;

#
#--- find out the last month
#

if($umon == 0){
        $lmonth = 12;
        $lyear = $year -1;
}else{
        $lmonth = $umon;
        $lyear  = $year;
}

#
#--- extract fits data from archive
#

system("perl $bin_dir/hrc_dose_get_data_full_rage.perl $lyear $lmonth $lyear $lmonth $usr $pass $mon_dir");

#
#--- create cumulative dose maps
#

system("perl $bin_dir/hrc_dose_make_cum_add_to_last.perl $mon_dir $cum_dir $lyear $lmonth");

#
#--- compute statistics
#

system("perl $bin_dir/hrc_dose_dff_comp_stat_month.perl $mon_dir  $data_out $lyear $lmonth");
system("perl $bin_dir/hrc_dose_acc_comp_stat_month.perl $cum_dir $data_out $lyear $lmonth");

#
#-- plot statistics 
#

system("perl $bin_dir/hrc_dose_plot_exposure_stat_section.perl $data_out  $plot_dir");

#
#--- create a html page for plotted data
#

system("perl $bin_dir/hrc_dose_make_data_html_full_range.perl $data_out");

#
#--- create png images from all fits images for the month
#

system("perl $bin_dir/hrc_dose_conv_to_png.perl $mon_dir $mon_dir $lyear $lmonth");
system("perl $bin_dir/hrc_dose_conv_to_png.perl $cum_dir $cum_dir $lyear $lmonth");

#
#--- copy data to "mays" which can be seen from the outer world
#

$emonth = $lmonth;
if($lmonth < 10 && $lmonth !~ /0/){
	$emonth = '0'."$lmonth";
}

$new_data = '*'."$emonth".'_'."$lyear".'*';

system("cp $mon_dir/$new_data $mays_dir/Month_hrc");

system("cp $cum_dir/$new_data $mays_dir/Cumulative_hrc");
