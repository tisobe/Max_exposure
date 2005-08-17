#!/usr/bin/perl

#########################################################################################
#                                                                                       #
#       hrc_dose_copy_data_to_may.perl: copy data to may so that the world can see it   #
#                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                       #
#       last update: Aug 17, 2005                                                       #
#                                                                                       #
#########################################################################################

###############################################################################
#---- set directories

$bin_dir  = '/data/mta/MTA4/bin/';				#---- this must be run from rhodes
$dat_dir  = '/data/mta/MTA4/data/';
$mon_dir  = '/data/mta_www/mta_max_exp/Month_hrc/';
$cum_dir  = '/data/mta_www/mta_max_exp/Cumulative_hrc/';
$data_out = '/data/mta/www/mta_max_exp/Data/';
$plot_dir = '/data/mta/www/mta_max_exp/Plots/';
$img_dir  = '/data/mta_www/mta_max_exp/Images';

$mays_dir = '/data/mays/MTA/Exposure/Hrc/';                     #----- copying data

###############################################################################

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
#--- copy data to "mays" which can be seen from the outer world
#

$emonth = $lmonth;
if($lmonth < 10 && $lmonth !~ /0/){
       $emonth = '0'."$lmonth";
}

$new_data = '*'."$emonth".'_'."$lyear".'*';

system("gzip $mon_dir/$new_data");
system("cp $mon_dir/$new_data $mays_dir/Month_hrc");

system("gzip $cum_dir/$new_data");
system("cp $cum_dir/$new_data $mays_dir/Cumulative_hrc");

