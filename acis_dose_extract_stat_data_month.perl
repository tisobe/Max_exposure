#!/usr/bin/perl

#################################################################################################
#												#
#	acis_dose_extract_stat_data_month.perl: extract statistics from ACIS fits data from	#
#					  I2, I3, S2, and S3					#
#				output is avg, min, max, 10th brightest				#
#												#
#	author: t. isobe (tisobe@cfa.harvard.edu)						#
#												#
#	last update: Apr 18, 2005								#
#												#
#################################################################################################	

$ftools = '/home/ascds/DS.release/otsbin/';

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
	print "Usage: acis_dose_extract_stat_data_month.perl ";
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

#-------- ACIS I2 Chip ----------------

$name1 = "$in_dir".'/ACIS_07_1999_'."$smonth".'_'."$year".'_i2.fits*';
$name2 = "$in_dir2".'/ACIS_'."$smonth".'_'."$year".'_i2.fits*';

$line = "$name1".'[1:1024,1:256]';
$out_name = 'i_2_n_0_acc_out';
comp_stat();

$line = "$name2".'[1:1024,1:256]';
$out_name = 'i_2_n_0_dff_out';
comp_stat();

$line = "$name1".'[1:1024,257:508]';            # the last few columns are dropped
$out_name = 'i_2_n_1_acc_out';  		# because they are bad columns and too bright
comp_stat();    # this applies for all CCDs

$line = "$name2".'[1:1024,257:508]';
$out_name = 'i_2_n_1_dff_out';
comp_stat();

$line = "$name1".'[1:1024,513:768]';
$out_name = 'i_2_n_2_acc_out';
comp_stat();

$line = "$name2".'[1:1024,513:768]';
$out_name = 'i_2_n_2_dff_out';
comp_stat();

$line = "$name1".'[1:1024,769:1020]';
$out_name = 'i_2_n_3_acc_out';
comp_stat();

$line = "$name2".'[1:1024,769:1020]';
$out_name = 'i_2_n_3_dff_out';
comp_stat();


#-------- ACIS I3 Chip ----------------

$name1 = "$in_dir".'/ACIS_07_1999_'."$smonth".'_'."$year".'_i3.fits*';
$name2 = "$in_dir2".'/ACIS_'."$smonth".'_'."$year".'_i3.fits*';

$line = "$name1".'[1:1024,769:1020]';
$out_name = 'i_3_n_0_acc_out';
comp_stat();

$line = "$name2".'[1:1024,769:1020]';
$out_name = 'i_3_n_0_dff_out';
comp_stat();

$line = "$name1".'[1:1024,513:768]';
$out_name = 'i_3_n_1_acc_out';
comp_stat();

$line = "$name2".'[1:1024,513:768]';
$out_name = 'i_3_n_1_dff_out';
comp_stat();

$line = "$name1".'[1:1024,257:508]';
$out_name = 'i_3_n_2_acc_out';
comp_stat();

$line = "$name2".'[1:1024,257:508]';
$out_name = 'i_3_n_2_dff_out';
comp_stat();

$line = "$name1".'[1:1024,1:256]';
$out_name = 'i_3_n_3_acc_out';
comp_stat();

$line = "$name2".'[1:1024,1:256]';
$out_name = 'i_3_n_3_dff_out';
comp_stat();


#-------- ACIS S2 Chip ----------------

$name1 = "$in_dir".'/ACIS_07_1999_'."$smonth".'_'."$year".'_s2.fits*';
$name2 = "$in_dir2".'/ACIS_'."$smonth".'_'."$year".'_s2.fits*';

$line = "$name1".'[1:256,1:1020]';
$out_name = 's_2_n_0_acc_out';
comp_stat();

$line = "$name2".'[1:256,1:1020]';
$out_name = 's_2_n_0_dff_out';
comp_stat();

$line = "$name1".'[257:508,1:1020]';
$out_name = 's_2_n_1_acc_out';
comp_stat();

$line = "$name2".'[257:508,1:1020]';
$out_name = 's_2_n_1_dff_out';
comp_stat();

$line = "$name1".'[513:768,1:1020]';
$out_name = 's_2_n_2_acc_out';
comp_stat();

$line = "$name2".'[513:768,1:1020]';
$out_name = 's_2_n_2_dff_out';
comp_stat();

$line = "$name1".'[769:1024,1:1020]';
$out_name = 's_2_n_3_acc_out';
comp_stat();

$line = "$name2".'[769:1024,1:1020]';
$out_name = 's_2_n_3_dff_out';
comp_stat();


#-------- ACIS S3 Chip ----------------


$name1 = "$in_dir".'/ACIS_07_1999_'."$smonth".'_'."$year".'_s3.fits*';
$name2 = "$in_dir2".'/ACIS_'."$smonth".'_'."$year".'_s3.fits*';

$line = "$name1".'[1:256,1:1020]';
$out_name = 's_3_n_0_acc_out';
comp_stat();

$line = "$name2".'[1:256,1:1020]';
$out_name = 's_3_n_0_dff_out';
comp_stat();

$line = "$name1".'[257:508,1:1020]';
$out_name = 's_3_n_1_acc_out';
comp_stat();

$line = "$name2".'[257:508,1:1020]';
$out_name = 's_3_n_1_dff_out';
comp_stat();

$line = "$name1".'[513:768,1:1020]';
$out_name = 's_3_n_2_acc_out';
comp_stat();

$line = "$name2".'[513:768,1:1020]';
$out_name = 's_3_n_2_dff_out';
comp_stat();

$line = "$name1".'[769:1024,1:1020]';
$out_name = 's_3_n_3_acc_out';
comp_stat();

$line = "$name2".'[769:1024,1:1020]';
$out_name = 's_3_n_3_dff_out';
comp_stat();

#-----------------------------


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
	system("dmcopy \"$line\" temp.fits");
#	system("$ftools/fimgstat temp.fits I/INDEF I/INDEF > result");
	system("$ftools/fimgstat temp.fits threshlo=1 threshup=I/INDEF > result");	#-- to avoid get min from outside of the edge of a CCD

	find_10th("temp.fits");						#-- find the 10th brightest ccd position and the count
	system("$ftools/fimgstat temp.fits threshlo=0 threshup=$upper > result2");
	system("rm temp.fits");
	print_stat();							#-- extract results and print data out
}

###########################################################################
###  sub print_stat: get a avg, dev, min, and max from fimgstat output  ###
###########################################################################

sub print_stat{
        open(IN,"./result");
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
	$out = "$out_dir".'/'."$out_name";
        open(OUT,">>$out");
        print OUT "$year\t$month\t$mean\t$dev\t$min\t$min_pos\t$max\t$max_pos\t$max2\t$max_pos2\n";
        close(OUT);
        print "$out_name: $year\t$month\t$mean\t$dev\t$min\t$min_pos\t$max\t$max_pos\t$max2\t$max_pos2\n";
        `rm result result2` ;
}


##########################################################################
### find_10th: finding 10th brightest pisxel position and the count    ###
##########################################################################

sub find_10th {

        system("$ftools/fimhisto temp.fits outfile.fits range=indef,indef binsize=1 clobber='yes'");
        system("$ftools/fdump outfile.fits zout - - clobber='yes'");
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

