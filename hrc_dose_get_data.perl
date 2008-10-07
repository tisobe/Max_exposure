#!/usr/bin/perl

#########################################################################################
#											#
#	hrc_dose_get_data.perl: obtain HRC Evt1 data for a month and create		#
#				 cumulative data fits file				#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last updated: 10/06/2008							#
#											#
#########################################################################################

#
#---- set directories
#

$temp_in = `cat ./dir_list3`;
@dir_list = split(/\s+/, $temp_in);

$chk = 0;
foreach (@dir_list){
	$chk++;
}
if($chk == 0){
	print "dir_list is not set\n";
	exit 1;
}

$bin_dir  = $dir_list[0];
$dat_dir  = $dir_list[1];
$lookup   = $dir_list[2];


$start_year  = $ARGV[0];
$start_month = $ARGV[1];
$end_year    = $ARGV[2];
$end_month   = $ARGV[3];
$user        = `cat $dat_dir/.dare`;
$hakama      = `cat $dat_dir/.hakama`;

$test = `ls -d `;
if($test =~ /Save/){
	system("rm ./Save/*");
}else{
	system("mkdir ./Save");
}

chomp $start_year;
chomp $start_month;
chomp $end_year;
chomp $end_month;
chomp $user;
chomp $hakama;
$user   =~ s/\s+//g;
$hakama =~ s/\s+//g;

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

		$out_file_i = './HRCI_'."$smonth".'_'."$year".'.fits';
		$out_file_s = './HRCS_'."$smonth".'_'."$year".'.fits';

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
		print OUT "operation=browse\n";
		print OUT "dataset=flight\n";
		print OUT "detector=hrc\n";
		print OUT "level=1\n";
		print OUT "filetype=evt1\n";
		print OUT "tstart=$line1\n";
		print OUT "tstop=$line2\n";
		print OUT "go\n";
		close(OUT);

		system('rm hrcf*evt1.fits*');

		`echo $hakama |arc4gl -U$user -Sarcocc -iinput_line > fits_list`;
		open(IN, "fits_list");
		@file_list = ();
		while(<IN>){
			chomp $_;
			@htemp = split(/\s+/, $_);
			if($htemp[0] =~ /hrcf/){
				push(@file_list, $htemp[0]);
			}
		}
		close(IN);
		system("rm fits_list");

		$hrci_cnt  = 0;
		$hrcs_cnt  = 0;

		foreach $file (@file_list){

			open(OUT, ">./input_line");
			print OUT "operation=retrieve\n";
			print OUT "dataset=flight\n";
			print OUT "detector=hrc\n";
			print OUT "level=1\n";
			print OUT "filetype=evt1\n";
			print OUT "filename=$file\n";
			print OUT "go\n";
			close(OUT);
	
			`echo $hakama |arc4gl -U$user -Sarcocc -iinput_line`;

			system("rm input_line");
			system('gzip -d *gz');

#
#---- classify each HRC file into S or I file.
#
			system("dmlist infile=$file outfile=zout opt=head");
			open(FH, './zout');
			OUTER:
			while(<FH>){
				chomp $_;
				if($_ =~/DETNAM/){
					@atemp = split(/\s+/, $_);
					$detector = $atemp[2];
					$detector =~s/\s+//g;
					last OUTER;
				}
			}
			close(FH);
			system("rm zout");
			if($detector =~ /HRC-S/i){

#
#----- HRC-S
#
				$line = "$file".'[EVENTS][bin rawx=0:4095:1, rawy=22528:26623:1][status=xxxxxx00xxxxxxxxx000x000xx00xxxx][option type=i4 mem=80]';
	
				system("dmcopy \"$line\" out.fits  option=image  clobber=yes");

				system("dmstat out.fits centroid=no > stest");
				open(FH, "./stest");
				$chk = 0;
				OUTER:
				while(<FH>){
					chomp $_;
					if($_ =~ /mean/){
						@atemp = split(/\s+/, $_);
						if($atemp[2] > 0){
							$chk = 1;
							last OUTER;
						}
					}
				}
				close(FH);


				if($chk > 0){
					$line ='out.fits[opt type=i4,null=-99]';
					system("dmcopy infile=\"$line\"  outfile=ztemp.fits clobber=yes");
		
				}
				system("rm out.fits");

				if($hrcs_cnt ==  0){
					system("mv ztemp.fits total_s.fits");
				}elsif($hrcs_cnt > 0){
					system("dmimgcalc infile=ztemp.fits infile2=total_s.fits outfile=mtemp.fits operation=add  clobber=yes");
					sytem("rm ztemp.fits");
					system("mv mtemp.fits total_s.fits");
				}
				$hrcs_cnt++;

			}else{
#
#---- HRC-I
#
				$line = "$file".'[EVENTS][bin rawx=6144:10239:1, rawy=6144:10239:1][status=xxxxxx00xxxxxxxxx000x000xx00xxxx][option type=i4 mem=80]';
				system("dmcopy \"$line\" out.fits  option=image clobber=yes");

				system("dmstat out.fits centroid=no > stest");
				open(FH, "./stest");
				$chk = 0;
				OUTER:
				while(<FH>){
					chomp $_;
					if($_ =~ /mean/){
						@atemp = split(/\s+/, $_);
						if($atemp[2] > 0){
							$chk = 1;
							last OUTER;
						}
					}
				}
				close(FH);


				if($chk > 0){
					$line ='out.fits[opt type=i4,null=-99]';
					system("dmcopy infile=\"$line\"  outfile=ztemp.fits clobber=yes");
				}
				system("rm out.fits");
				if($hrci_cnt ==  0){
					system("mv ztemp.fits total_i.fits");
				}elsif($hrci_cnt > 0){
					system("dmimgcalc infile=ztemp.fits infile2=total_i.fits outfile=mtemp.fits operation=add  clobber=yes");
					system("rm ztemp.fits");
					system("mv mtemp.fits total_i.fits");
				}
				$hrci_cnt++;
			}

			
		system("rm $file");
		}
		if($hrcs_cnt > 0){
			system("mv total_s.fits Save/$out_file_s");
		}
		if($hrci_cnt > 0){
			system("mv total_i.fits Save/$out_file_i");
		}
	}
}
