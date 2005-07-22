#!/usr/bin/perl

#################################################################################################
#												#
#	hrc_dose_make_cum_add_to_last.perl: make cumulative hrc dose map for the month given	#
#				 		 to the given date				#
#												#
#		author: t. isobe (tisobe@cfa.harvard.edu)					#
#												#
#		last update: Jun 13, 2005							#
#												#
#################################################################################################

$ftools = '/home/ascds/DS.release/otsbin/';

$in_dir  = $ARGV[0];	#----- directory contains hrc maps for each month
$cum_dir = $ARGV[1];	#----- directory contains hrc cumultavie data
$tyear   = $ARGV[2];	#----- the year ending the accumulation
$tmonth  = $ARGV[3];	#----- the month ending the accumulation
chomp $in_dir;
chomp $cum_dir;
chomp $tyear;
chomp $tmonth;

$lmonth = $tmonth -1;
if ($lmonth < 1){
	$lmonth = 12;
	$lyear = $tyear -1;
}else{
	$lyear = $tyear;
}
if($tmonth < 10 && $tmonth !~ /^0/){
	$tmonth = '0'."$tmonth";
}
if($lmonth < 10 && $lmonth !~ /^0/){
	$lmonth = '0'."$lmonth";
}


foreach $inst ('HRCI', 'HRCS'){
	OUTER:
	for($m = 0; $m < 10; $m++){			#----section indicator
		if($m == 9 && $inst eq 'HRCI'){
			next OUTER;
		}
		$lname = "$cum_dir".'/'."$inst".'_09_1999_'."$lmonth".'_'."$lyear".'_'."$m".'.fits*';
		$name  = "$in_dir".'/'."$inst".'_'."$tmonth".'_'."$tyear".'_'."$m".'.fits*';
		$out   = "$cum_dir".'/'."$inst".'_09_1999_'."$tmonth".'_'."$tyear".'_'."$m".'.fits';

		$test = `ls $name`;
		chomp $test;
		if($test =~ /$inst/){
			system("$ftools/chimgtyp $name temp3.fits datatype=DOUBLE Inull=-99 clobber=yes");
			open(OUT, '>file');
			print OUT "temp3.fits,0,0\n";
			close(OUT);
			system("$ftools/fimgmerge $lname \@file ./zout.fits  clobber=yes");
			system("mv ./zout.fits $out");
			system("gzip $out");
		}else{
			$out2 = "$out".'.gz';
			system("cp $lname $out2");
		}
	}
}
