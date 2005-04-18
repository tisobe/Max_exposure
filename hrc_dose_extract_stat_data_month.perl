#!/usr/bin/perl

#################################################################################################
#												#
#	hrc_dose_extract_stat_data_month.perl: extract statistics from HRC S and I files	#
#				output is avg, min, max,               				#
#												#
#	author: t. isobe (tisobe@cfa.harvard.edu)						#
#												#
#	last update: Mar 23, 2005								#
#												#
#################################################################################################	

$year    = $ARGV[0];
$month   = $ARGV[1];
$in_dir  = $ARGV[2];
$in_dir2 = $ARGV[3];
$out_dir = $ARGV[4];
chomp $year;
chomp $month;
chomp $in_dir;
chomp $in_dir2;
chomp $out_dir;

if($year eq '' || $month eq '' || $in_dir eq '' || $in_dir2 eq '' || $out_dir eq ''){
        print "Usage: hrc_dose_extract_stat_data_month.perl ";
        print "<year> <month> <accum data dir> <one month data dir> <output dir>\n";
        exit 1;
}

$smonth = $month;
if($month < 10){
        @atemp =  split(//, $month);
        if($atemp[0] ne '0'){
                $smonth = '0'."$month";
        }
}


##################################

#
#----- file names
#
		$name1 = "$in_dir".'/HRCS_08_1999_'."$smonth".'_'."$year".'.fits*';
		$name2 = "$in_dir2".'/HRCS_'."$smonth".'_'."$year".'.fits*';

		$name3 = "$in_dir".'/HRCI_08_1999_'."$smonth".'_'."$year".'.fits*';
		$name4 = "$in_dir2".'/HRCI_'."$smonth".'_'."$year".'.fits*';

		$line = $name1;
		$out_name = 'hrcs_acc_out';
		comp_stat();

		$line = $name2;
		$out_name = 'hrcs_dff_out';
		comp_stat();

		$line = $name3;
		$out_name = 'hrci_acc_out';
		comp_stat();

		$line = $name4;
		$out_name = 'hrci_dff_out';
		comp_stat();


######################################################################
### month_rum_to_lett: convert month name from num to letters     ####
######################################################################

sub month_num_to_lett{
	my($tmonth);
	($tmonth) = @_;
        if($tmonth == 1){
                $cmonth = 'JAN';
        }elsif($tmonth == 2){
                $cmonth = 'FEB';
        }elsif($tmonth == 3){
                $cmonth = 'MAR';
        }elsif($tmonth == 4){
                $cmonth = 'APR';
        }elsif($tmonth == 5){
                $cmonth = 'MAY';
        }elsif($tmonth == 6){
                $cmonth = 'JUN';
        }elsif($tmonth == 7){
                $cmonth = 'JUL';
        }elsif($tmonth == 8){
                $cmonth = 'AUG';
        }elsif($tmonth == 9){
                $cmonth = 'SEP';
        }elsif($tmonth == 10){
                $cmonth = 'OCT';
        }elsif($tmonth == 11){
                $cmonth = 'NOV';
        }elsif($tmonth == 12){
                $cmonth = 'DEC';
        }
}

###########################################################################
### comp_stat: compute statistics using ftools                          ###
###########################################################################

sub comp_stat{
print "$line\n";
	$ztest = `ls $line`;
	if($ztest =~ /$line/){
		system("fimgstat $line threshlo=0 threshup=I/INDEF > result");	#-- to avoid get min from outside of the edge of a CCD
	
		$upper = 'I/INDEF';
		$chk = `cat ./result`;
		if($chk =~ /mean/){
			$upper = find_10th("$line");				#-- find the 10th brightest ccd position and the count
			system("fimgstat $line threshlo=0 threshup=$upper > result2");
		}
	}else{
		open(ZZ, '> result');
		close(ZZ);
		open(ZZ, '> result2');
		close(ZZ);
	}
	print_stat();							#-- extract results and print data out
}

###########################################################################
###  sub print_stat: get a avg, dev, min, and max from fimgstat output  ###
###########################################################################

sub print_stat{
        open(IN,"./result");
	$mean = 'NA';
	$dev  = 'NA';
	$min  = 'NA';
	$max  = 'NA';
	$min_pos = 'NA';
	$max_pos = 'NA';

	$mean2 = 'NA';
	$dev2  = 'NA';
	$min2  = 'NA';
	$max2  = 'NA';
	$min_pos2 = 'NA';
	$max_pos2 = 'NA';

        while(<IN>) {
                chomp $_;
                @atemp = split(/=/,$_);
                if($atemp[0] eq 'The mean of the selected image                '){
                        $mean = $atemp[1];
                }elsif($atemp[0] eq 'The standard deviation of the selected image  '){
                        $dev = $atemp[1];
                }elsif($atemp[0] eq 'The minimum of selected image                 '){
                        $min = $atemp[1];
                }elsif($atemp[0] eq 'The maximum of selected image                 '){
                        $max = $atemp[1];
                }elsif($atemp[0] eq 'The location of minimum is at pixel number    '){
			$min_pos = $atemp[1];
		}elsif($atemp[0] eq 'The location of maximum is at pixel number    '){
			$max_pos = $atemp[1];
		}
        }
        close(IN);
#
#------ stat for 10th brightest case
#
        open(IN,"./result2");
        while(<IN>) {
                chomp $_;
                @atemp = split(/=/,$_);
                if($atemp[0] eq 'The mean of the selected image                '){
                        $mean2 = $atemp[1];
                }elsif($atemp[0] eq 'The standard deviation of the selected image  '){
                        $dev2 = $atemp[1];
                }elsif($atemp[0] eq 'The minimum of selected image                 '){
                        $min2 = $atemp[1];
                }elsif($atemp[0] eq 'The maximum of selected image                 '){
                        $max2 = $atemp[1];
                }elsif($atemp[0] eq 'The location of minimum is at pixel number    '){
			$min_pos2 = $atemp[1];
		}elsif($atemp[0] eq 'The location of maximum is at pixel number    '){
			$max_pos2 = $atemp[1];
		}
        }
        close(IN);
        open(OUT,">>$out_name");
        print OUT "$year\t$month\t$mean\t$dev\t$min\t$min_pos\t$max\t$max_pos\t$max2\t$max_pos2\n";
        close(OUT);
        `rm result result2` ;
}


##########################################################################
### find_10th: finding 10th brightest pisxel position and the count    ###
##########################################################################

sub find_10th {
	
	($fzzz) = @_;
        system("fimhisto $fzzz outfile.fits range=indef,indef binsize=1 clobber='yes'");
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
	$upper = $hbin[$tot-10];
	system("rm outfile.fits zout");
}

