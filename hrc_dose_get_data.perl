#!/usr/bin/perl

#########################################################################################
#											#
#	hrc_dose_get_data.perl: obtain ACIS Evt2 data for a month and create		#
#				 cumulative data fits file				#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last updated: 03/25/2005							#
#											#
#########################################################################################

$start_year  = $ARGV[0];
$start_month = $ARGV[1];
$end_year    = $ARGV[2];
$end_month   = $ARGV[3];
$user        = $ARGV[4];
$hakama      = $ARGV[5];

chomp $start_year;
chomp $start_month;
chomp $end_year;
chomp $end_month;

if($start_year !~/\d/ || $start_month !~/\d/ || $end_year!~ /\d/ || $end_month !~ /\d/
				 || $user eq '' || $hakama eq ''){
		print "usage: perl acis_dose_get_data.perl ";
		print "<start year> <start month> <end year> <end month>\n";
		exit 1;
}

$test = `ls `;
if($test !~ /param/){
	system("mkdir param");
}

$month_list1 = ();
$month_list2 = ();
$month_list3 = ();

$chk = 0;

if($start_year == $end_year){
	for($i = $start_month; $i <= $end_month; $i++){
		push(@month_list2, $i);
	}
	$chk++;
}else{
	for($i = $start_month; $i <=12; $i++){
		push(@month_list1, $i);
	}
	for($i = 1; $i <= $end_month; $i++){
		push(@month_list3, $i);
	}
	@month_list2 = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
}

for($year = $start_year; $year <= $end_year; $year++){
	@atemp = split(//, $year);
	$short_year = "$atemp[2]$atemp[3]";
	if($chk == 1){
		@month_list = @month_list2;
	}else{
		if($year == $start_year){
			@month_list = @month_list1;
		}elsif($year == $end_year){
			@month_list = @month_list3;
		}else{
			@month_list = @month_list2;
		}
	}
	OUTER:
	foreach $month (@month_list){
		$smonth = $month;
		if($month < 10){
			$smonth = '0'."$month";
		}

		$out_file_i = '/HRCI_'."$smonth".'_'."$year".'.fits';
		$out_file_s = '/HRCS_'."$smonth".'_'."$year".'.fits';

		$line1 = "$smonth/01/$short_year".',00:00:00';
		$next_month = $month+1;
		if($next_month > 12){
			$next_month = '01';
			$next_year  = $short_year + 1;
			if($next_year == 100){
				$next_year = '00';
			}
			$line2 = "$next_month".'/01/'."$next_year".',00:00:00';
		}else{
			if($next_month < 10){
				$next_month = '0'."$next_month";
			}
			$line2 = "$next_month".'/01/'."$short_year".',00:00:00';
		}

		open(OUT, ">./input_line");
		print OUT "operation=retrieve\n";
		print OUT "dataset=flight\n";
		print OUT "detector=hrc\n";
		print OUT "level=1\n";
		print OUT "filetype=evt1\n";
		print OUT "tstart=$line1\n";
		print OUT "tstop=$line2\n";
		print OUT "go\n";
		close(OUT);

		system('rm hrcf*evt1.fits*');
		`echo $hakama |arc4gl -U$user -Sarcocc -iinput_line`;
		system('gzip -d *gz');
		$list = `ls hrcf*evt1.fits*`;

		@list = split(/\s+/, $list);
		$cnt = 0;
		@hrci_list = ();
		$hrci_cnt  = 0;
		@hrcs_list = ();
		$hrcs_cnt  = 0;

		foreach $file (@list){
			system("fdump $file zout - 1 clobber='yes'");
			open(FH, './zout');
			OUTER:
			while(<FH>){
				chomp $_;
				if($_ =~/DETNAM/){
					@atemp = split(/\'/, $_);
					$detector = $atemp[1];
					$detector =~s/\s+//g;
					last OUTER;
				}
			}
			close(FH);
			system("rm zout");
			if($detector =~ /HRC-S/i){
				push(@hrcs_list, $file);
				$hrcs_cnt++;
			}else{
				push(@hrci_list, $file);
print "$file\n";
				$hrci_cnt++;
			}
		}

#
#----- HRC-S
#

		if($hrcs_cnt > 0){
			if($hrcs_cnt == 1){
				$file = shift(@hrcs_list);
				system("mv $file Save/$out_file_s");
			}else{
				$first =  shift(@hrcs_list);
				
				$line = "$first".'[EVENTS][bin rawx=0:4095:1, rawy=22528:26623:1][status=xxxxxx00xxxxxxxxx000x000xx00xxxx][option type=i4 mem=80]';
	
				system("dmcopy \"$line\" out.fits  option=image  clobber=yes");

				system("chimgtyp out.fits  total.fits datatype=LONG Inull=-99 clobber=yes");
				system("echo total.fits,0,0 > file");
		
				system("rm $first");

				OUTER:
				foreach $file (@hrcs_list){

					$line = "$file".'[EVENTS][bin rawx=0:4095:1, rawy=22528:26623:1][status=xxxxxx00xxxxxxxxx000x000xx00xxxx][option type=i4 mem=80]';
					if (-e 'out.fits') {unlink 'out.fits';}
					system("dmcopy \"$line\" out.fits  option=image clobber=yes");
	
					$check = `ls total.fits`;
					system("chimgtyp out.fits temp3.fits datatype=LONG Inull=-99 clobber=yes");
					if($check !~ /total/){
						system("mv temp3.fits total.fits");
						next OUTER;
					}
					system("fimgmerge temp3.fits \@file mtemp.fits");
					system("mv mtemp.fits total.fits");
					system("rm $file");
				}
				system("mv total.fits Save/$out_file_s");
			}
		}
#
#---- HRC-I
#
		if($hrci_cnt > 0){
			if($hrci_cnt == 1){
				$file = shift(@hrci_list);
				system("mv $file Save/$out_file_s");
			}else{
				$first =  shift(@hrci_list);
				
				$line = "$first".'[EVENTS][bin rawx=6144:10239:1, rawy=6144:10239:1][status=xxxxxx00xxxxxxxxx000x000xx00xxxx][option type=i4 mem=80]';
	
				system("dmcopy \"$line\" out.fits  option=image clobber=yes");

				system("chimgtyp out.fits  total.fits datatype=LONG Inull=-99 clobber=yes");
				system("echo total.fits,0,0 > file");
		
 				system("rm $first");

				OUTER:
				foreach $file (@hrci_list){

					$line = "$file".'[EVENTS][bin rawx=6144:10239:1, rawy=6144:10239:1][status=xxxxxx00xxxxxxxxx000x000xx00xxxx][option type=i4 mem=80]';
					if (-e 'out.fits') {unlink 'out.fits';}
					system("dmcopy \"$line\" out.fits  option=image clobber=yes");
					$check = `ls total.fits`;
					system("chimgtyp out.fits temp3.fits datatype=LONG Inull=-99 clobber=yes");
					if($check !~ /total/){
						system("mv temp3.fits total.fits");
						next OUTER;
					}
					system("fimgmerge temp3.fits \@file mtemp.fits");
					system("mv mtemp.fits total.fits");
					system("rm $file");
				}
				system("mv total.fits Save/$out_file_i");
			}
		}
	}
	system("rm hrcf*.fits");
}
