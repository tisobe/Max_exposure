#!/usr/bin/perl

#########################################################################################################
#													#
#	hrc_dose_dff_comp_stat_month.perl: compute statistics of hrc monthly data for a specified month	#
#													#
#		author: t. isobe (tisobe@cfa.harvard.edu)						#
#													#
#		last update: Aug 18, 2005								#
#													#
#########################################################################################################

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
		$out   = "$outdir".'/'."$lower".'_'."$sec".'_dff';
		$name  = "$indir".'/'."$header".'_'."$tmonth".'_'."$tyear".'_'."$sec".'.fits.*';

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
		system('dmstat infile=$name centroid=0 > zstat");
		open(FH, './zstat');
		while(<FH>){
			chomp $_;
			@atemp = split(/\s+/, $_);
			if($_ =~ /mean/){
				$mean = $atemp[2];
				$mean =~ s/\s+//g;
			}elsif($_ =~ /std/){
				$std  = $atemp[2];
				$std  =~ s/\s+//g;
			}elsif($_ =~ /min/){
				$min     = $atemp[2];
				$min     =~ s/\s+//g;
				$min_loc = $atemp[4];
				$min_loc =~ s/\s+//g;
			}elsif($_ =~ /max/){
				$max     = $atemp[2];
				$max     =~ s/\s+//g;
				$max_loc = $atemp[4];
				$max_loc =~ s/\s+//g;
			}
		}
		close(FH);

		system("rm zstat");

                find_10th("$name");

		system("dmimgthresh infile=$name outfile=zthresh.fits  cut=\"0:$upper\" value=0 clobber=yes");
		system("dmstat infile=zthresh.fits centroid=no > zstat");
		system("rm zthresh.fits");

                open(FH, './zstat');
                while(<FH>){
                        chomp $_;
                        @atemp = split(/\s+/, $_);
                        if($_ =~ /max/){
                                $max10  = $atemp[2];
                                $max10  =~ s/\s+//g;
                                $max10_loc = $atemp[4];
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
	system("dmimghist infile=$fzzz outfile=outfile.fits 1::1 strict clobber=yes");
	system("dmlist infile=outfile.fits outfile=./zout opt=data");

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

