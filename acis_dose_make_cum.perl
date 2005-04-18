#!/usr/bin/perl

$in_dir = $ARGV[0];
$tyear  = $ARGV[1];
$tmonth = $ARGV[2];
chomp $in_dir;
chomp $tyear;
chomp $tmonth;

OUTER:
for($year = 1999; $year <= $tyear; $year++){
	OUTER1:
	for($month = 1; $month < 13; $month++){
		if($year == 1999 && $month < 7){
			next OUTER1;
		}elsif($year == $tyear  && $month > $tmonth){
			last OUTER;
		}
		$cmonth = $month;
		if($month < 10){
			$cmonth = '0'."$month";
		}
		$name = "$in_dir".'/ACIS_'."$cmonth".'_'."$year".'.fits*';
		$out  = 'ACIS_07_1999_'."$cmonth".'_'."$year".'.fits';
		if($year == 1999 && $month == 7){
			system("cp $name $out");
			system("cp $name temp.fits");
			system("chimgtyp temp.fits temp2.fits datatype=DOUBLE Inull=-99 clobber=yes");
			system("mv temp2.fits temp.fits");
			next OUTER1;
		}
		
		system("chimgtyp $name temp3.fits datatype=DOUBLE Inull=-99 clobber=yes");
		open(OUT, '>file');
		print OUT "temp3.fits,0,0\n";
		close(OUT);
		system("fimgmerge temp.fits \@file $out clobber=yes");
		system("cp $out temp.fits");
	}
}
