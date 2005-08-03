#!/usr/bin/perl

#########################################################################################
#											#
#	hrc_create_center_dose_map.perl: a master script to create center HRC dose map	#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Jul 22, 2005							#
#											#
#########################################################################################

$ftools = '/home/ascds/DS.release/otsbin/';

$bin_dir  = '/data/mta4/MTA/bin/';		# this works only from rhodes
$dat_dir  = '/data/mta4/MTA/data/';
$mon_dir  = '/data/mta/Script/Exposure/Month_hrc/';
$cum_dir  = '/data/mta/Script/Exposure/Cumulative_hrc/';
$data_out = '/data/mta/www/mta_max_exp/Data/';
$plot_dir = '/data/mta/www/mta_max_exp/Plots/';
$img_dir  = '/data/mta_www/mta_max_exp/Images';


$usr = `cat $dat_dir/.dare`;
$pass = `cat $dat_dir/.hakama`;
chomp $usr;
chomp $pass;

$chk = `ls -d`;
if($chk !~ /param/){
	system("mkdir param");
}

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
#--- two month ago
#

$tmonth = $lmonth -1;
$tyear  = $lyear;
if($tmonth < 1){
	$tmonth = 12;
	$tyear--;
}

#
#--- extract fits data from archive
#

system("perl $bin_dir/hrc_dose_get_data.perl $lyear $lmonth $lyear $lmonth $usr $pass");

system("mv ./Save/HRC*fits $mon_dir");
system("rm -rf Save");

$dlmonth = $lmonth;
if($dlmonth < 10){
	$dlmonth = '0'."$dlmonth";
}
$dtmonth = $tmonth;
if($dtmonth < 10){
	$dtmonth = '0'."$dtmonth";
}

#
#--- create cumulative HRC dose maps
#

foreach $inst ('HRCI', 'HRCS'){
	$tname = "$cum_dir".'/'."$inst".'_08_1999_'."$dtmonth".'_'."$tyear".'.fits*';
	$name  = "$mon_dir".'/'."$inst".'_'."$dlmonth".'_'."$lyear".'.fits*';
	$out   = "$cum_dir".'/'."$inst".'_08_1999_'."$dlmonth".'_'."$lyear".'.fits';
	$test  = `ls $name`;
	chomp $test;
	if($test =~ /$name/){
		system("$ftools/chimgtyp $name temp3.fits datatype=DOUBLE Inull=-99 clobber=yes");
		open(OUT, '>file');
		print OUT "temp3.fits,0,0\n";
		close(OUT);
		system("$ftools/fimgmerge $tname \@file ./zout.fits  clobber=yes");
		system("mv ./zout.fits $out");
		system("gzip $out");
	}else{
		$out2 = "$out".'.gz';
		system("cp $tname $out2");
	}
}
system("rm file temp3.fits");

#
#--- compute statistics
#

system("perl $bin_dir/hrc_dose_extract_stat_data_month.perl $lyear $lmonth $cum_dir $mon_dir $data_out");

#
#--- plot statistics
#

system("perl $bin_dir/hrc_dose_plot_exposure_stat.perl $data_out  $plot_dir");

#
#--- create data html page
#

system("perl $bin_dir/hrc_dose_make_data_html.perl $data_out");

#
#--- create png images from fits data
#

system("perl $bin_dir/hrc_dose_conv_to_png.perl $mon_dir $img_dir $lyear $lmonth");
system("perl $bin_dir/hrc_dose_conv_to_png.perl $cum_dir $img_dir $lyear $lmonth");

system("rm file input_line out.fits pgplot.ps");
