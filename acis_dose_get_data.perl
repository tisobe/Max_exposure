#!/usr/bin/perl

#########################################################################################
#											#
#	acis_dose_get_data.perl: obtain ACIS Evt1 data for a month and create		#
#				 cumulative data fits file				#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last updated: 04/18/2005							#
#											#
#########################################################################################

$start_year  = $ARGV[0];
$start_month = $ARGV[1];
$end_year    = $ARGV[2];
$end_month   = $ARGV[3];
$user        =`cat /data/mta4/MTA/data/.dare`;
$hakama      = `cat /data/mta4/MTA/data/.hakama`;

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
		print "<start year> <start month> <end year> <end month> <user name> <pwd>\n";
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

		$out_file = 'ACIS_'."$smonth".'_'."$year".'.fits';

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
		print OUT "detector=acis\n";
		print OUT "level=1\n";
		print OUT "filetype=evt1\n";
		print OUT "tstart=$line1\n";
		print OUT "tstop=$line2\n";
		print OUT "go\n";
		close(OUT);

		`echo $hakama |arc4gl -U$user -Sarcocc -iinput_line > zzz`;

		@list = ();
		open(IN, './zzz');
		while(<IN>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			if($atemp[0] =~ /acisf/ && $atemp[1] > 5000){
				push(@list, $atemp[0]);
			}elsif($atemp[1] =~ /acisf/ && $atemp[2] > 5000){
				push(@list, $atemp[1]);
			}elsif($atemp[2] =~ /acisf/ && $atemp[3] > 5000){
				push(@list, $atemp[2]);
			}
		}
		close(IN);
		system("rm zzz");

		$first = shift(@list);
		@new = ($first);
		OUTER:
		foreach $ent (@list){
			foreach $comp (@new){
				if($ent eq $comp){
					next OUTER;
				}
			}
			push(@new, $ent);
		}
		$first = shift(@new);
		@atemp = split(/acisf/, $first);
		@btemp = split(/_/, $atemp[1]);
		$obsid = $btemp[0];
		
		open(OUT, ">./input_line");
		print OUT "operation=retrieve\n";
		print OUT "dataset=flight\n";
		print OUT "detector=acis\n";
		print OUT "level=1\n";
		print OUT "filetype=evt1\n";
#		print OUT "obsid=$obsid\n";
		print OUT "filename=$first\n";
		print OUT "go\n";
		close(OUT);

		`echo $hakama |arc4gl -U$user -Sarcocc -iinput_line`;

		system("gzip -d -f  *gz");

		$line = "$first".'[EVENTS][bin tdetx=2800:5200:1, tdety=1650:4150:1][option type=i4]';
		system("dmcopy \"$line\" out.fits  option=image clobber=yes");

		system("chimgtyp out.fits  total.fits datatype=LONG Inull=-99 clobber=yes");
		system("echo total.fits,0,0 > file");

		system("rm $first");

		OUTER:
		foreach $file (@new){
			@atemp = split(/acisf/, $file);
			@btemp = split(/_/, $atemp[1]);
			$obsid = $btemp[0];
			
			open(OUT, ">./input_line");
			print OUT "operation=retrieve\n";
			print OUT "dataset=flight\n";
			print OUT "detector=acis\n";
			print OUT "level=1\n";
			print OUT "filetype=evt1\n";
#			print OUT "obsid=$obsid\n";
			print OUT "filename=$file\n";
			print OUT "go\n";
			close(OUT);
	
			`echo $hakama |arc4gl -U$user -Sarcocc -iinput_line`;
	
			system("gzip -d  *gz");

			$line = "$file".'[EVENTS][bin tdetx=2800:5200:1, tdety=1650:4150:1][option type=i4]';
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
		system("rm acisf*fits*");
		system("mv total.fits $out_file");
	}
}

##########################################################################
### Following two sub scripts are not used in this script              ###
##########################################################################

sub comp_stat{
                my($file_name, $upper, $max, $ftemp);
                ($file_name, $upper) = @_;

                system("fimgstat $file_name threshlo=0 threshup=$upper > zstat");
                open(SFH, './zstat');
                while(<SFH>){
                        chomp $_;
                        if($_ =~ /The maximum/){
                                @ftemp = split(/=/, $_);
                                $max = $ftemp[1];
                                $max =~ s/\s+//;
                        }
			if($_ =~ /The location of maximum is at pixel number/){
				@ftemp = split(/=/, $_);
				$location = $ftemp[1];
			}
                }
		close(SFH);
                system("rm zstat");
                return $max;
}

##########################################################################
### find_10th: finding 10th brightest pisxel position and the count    ###
##########################################################################

sub find_10th {
        my($file_name, $upper);
        ($file_name) = @_;

        system("fimhisto $file_name  outfile.fits range=indef,indef binsize=1 clobber='yes'");
        system("fdump outfile.fits zout - - clobber='yes'");
        open(FH, './zout');
        @hbin = ();
        @hcnt = ();
        $tot = 0;
        while(<FH>){
                chomp $_;
                @htemp = split(/\s+/, $_);
                if($htemp[1] =~ /\d/ && $htemp[2] =~ /\d/ && $htemp[3] > 0){
                        push(@hbin, $htemp[1]);
                        push(@hcnt, $htemp[3]);
                        $tot++;
                }
        }
        close(FH);
        $upper = $hbin[$tot-11];
        if($tot < 10 || $upper ==  0){
                $upper = "I/INDEF";
        }
        system("rm outfile.fits zout");
	return $upper;
}

