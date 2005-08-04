#!/usr/bin/perl

#########################################################################################################
#													#
#	hrc_dose_acc_comp_stat_month.perl: compute statistics of hrc monthly data for a specified month	#
#					   (cumulative data)						#
#													#
#		author: t. isobe (tisobe@cfa.harvard.edu)						#
#													#
#		last update: Jun 13, 2005								#
#													#
#########################################################################################################

$ftools = '/home/ascds/DS.release/otsbin/';

$indir  = $ARGV[0];					#--- data file location
$outdir = $ARGV[1];					#--- stat data directory
$tyear  = $ARGV[2];					#--- year of the data
$tmonth = $ARGV[3];					#--- month of the data
chomp $indir;
chomp $outdir;
chomp $tyear;
chomp $tmomth;
if($tmonth < 10){
	$tmonth = '0'."$tmonth";
}

foreach $header ('HRCS', 'HRCI'){
	OUTER:
	for($sec = 0; $sec < 10; $sec++){		#---- section indicator
		if($header eq 'HRCI' && $sec > 8){
			next OUTER;
		}
		$lower = lc $header;
		$out   = "$outdir".'/'."$lower".'_'."$sec".'_acc';
		$name  = "$indir".'/'."$header".'_09_1999_'."$tmonth".'_'."$tyear".'_'."$sec".'.fits.*';

		system("ls $name");
		$test = `ls $indir/*`;
		if($test !~ /$name/){
			open(OUT, ">>$out");
			print OUT  "$tyear\t $tmonth\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\n";
			close(OUT);
			next OUTER;
		}
		system("$ftools/fimgstat $name i/inf i/inf > zstat");
		open(FH, './zstat');
		while(<FH>){
			chomp $_;
			@atemp = split(/=/, $_);
			if($_ =~ /The mean of the selected image/){
				$mean = $atemp[1];
				$mean =~ s/\s+//g;
			}elsif($_ =~ /The standard deviation/){
				$std  = $atemp[1];
				$std  =~ s/\s+//g;
			}elsif($_ =~ /The minimum of selected image/){
				$min  = $atemp[1];
				$min  =~ s/\s+//g;
			}elsif($_ =~ /The maximum of selected/){
				$max  = $atemp[1];
				$max  =~ s/\s+//g;
			}elsif($_ =~ /The location of minimum/){
				$min_loc = $atemp[1];
				$min_loc =~ s/\s+//g;
			}elsif($_ =~ /The location of maximum/){
				$max_loc = $atemp[1];
				$max_loc =~ s/\s+//g;
			}
		}
		close(FH);

		system("rm zstat");

                find_10th("$name");
                system("$ftools/fimgstat $name threshlo=0 threshup=$upper > zstat");
                open(FH, './zstat');
                while(<FH>){
                        chomp $_;
                        @atemp = split(/=/, $_);
                        if($_ =~ /The maximum of selected/){
                                $max10  = $atemp[1];
                                $max10  =~ s/\s+//g;
                        }elsif($_ =~ /The location of maximum/){
                                $max10_loc = $atemp[1];
                                $max10_loc =~ s/\s+//g;
                        }
                }
                close(FH);

		system("rm zstat");

		open(OUT, ">>$out");
		if($mean =~ /\d/){
			print OUT  "$tyear\t $tmonth\t";
			print OUT  "$mean\t";
			print OUT  "$std\t";
			print OUT  "$min\t";
			print OUT  "$min_loc\t";
			print OUT  "$max10\t";
			print OUT  "$max10_loc\t";
			print OUT  "$max\t";
			print OUT  "$max_loc\n";
		}else{
			print OUT  "$tyear\t $tmonth\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\t";
			print OUT  "NA\n";
		}
		close(OUT);
	}
}


##########################################################################
### find_10th: finding 10th brightest pisxel position and the count    ###
##########################################################################

sub find_10th {

        ($fzzz) = @_;
        system("$ftools/fimhisto $fzzz outfile.fits range=indef,indef binsize=1 clobber='yes'");
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
	if($upper !~ /\d/){
		$upper = 0;
	}
        system("rm outfile.fits zout");
}

