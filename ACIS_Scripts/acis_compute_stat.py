#!/usr/local/bin/python2.6

#########################################################################################
#                                                                                       #
#       acis_compute_stat: compute statistics for given month data                      #
#                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                       #
#       last updated: Jul 10, 2012                                                      #
#                                                                                       #
#########################################################################################

import sys
import os
import string
import re

#
#--- reading directory list
#

path = '/data/mta/Script/Exposure/house_keeping2/acis_dir_list'
f    = open(path, 'r')
data = [line.strip() for line in f.readlines()]
f.close()

for ent in data:
    atemp = re.split(':', ent)
    var  = atemp[1].strip()
    line = atemp[0].strip()
    exec "%s = %s" %(var, line)

#
#--- append path to a private folder
#

sys.path.append(mta_dir)
sys.path.append(bin_dir)

#
#--- converTimeFormat contains MTA time conversion routines
#
import convertTimeFormat as tcnv
#
#--- mta common functions
#
import mta_common_functions as mtac

#
#--- Exposure related funcions shared
#

import exposureFunctions as expf

#-----------------------------------------------------------------------------------------------------------
#-- comp_stat: compute statistics and print them out                                                     ---
#-----------------------------------------------------------------------------------------------------------

def comp_stat(line, year, month, outfile):

    """
    compute statistics and print them out
    input: command line, year, month, and output file name
           command line is used by dmcopy to extract a specific location 
           Example: ACIS_04_2012.fits.gz[1:1024,1:256]
    """

    cmd = 'dmcopy ' + line + ' temp.fits clobber="yes"'
    os.system(cmd)

#
#-- to avoid get min from outside of the edge of a CCD
#

    try:
        os.system('dmimgthresh infile=temp.fits  outfile=zcut.fits  cut="0:1e10" value=0 clobber=yes')
        os.system('dmstat  infile=zcut.fits  centroid=no > ./result')
        os.system('rm zcut.fits')

#
#-- find the 10th brightest ccd position and the count
#

#        upper = find_10th('temp.fits')
#
#        cmd   = 'dmimgthresh infile=temp.fits  outfile=zcut.fits  cut="0:' + str(upper) + '" value=0 clobber=yes'
#        os.system(cmd)
#        os.system('dmstat  infile=zcut.fits  centroid=no > ./result2')
#        os.system('rm  zcut.fits')
   
        print_stat('./result', './result2', year, month, outfile)
#        os.system('rm result result2')
        os.system('rm result')
    except:
        pass

    os.system('rm temp.fits')


#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------

def find_10th(fits_file):

    """
    find 10th brightest value    input: fits file
    """
#
#-- make histgram
#
    cmd = ' dmimghist infile=' + fits_file + '  outfile=outfile.fits hist=1::1 strict=yes clobber=yes'
    os.system(cmd)
    os.system('dmlist infile=outfile.fits outfile=./zout opt=data')

    f    = open('./zout', 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()
    os.system('rm outfile.fits ./zout')
#
#--- read bin # and its count rate
#
    hbin = []
    hcnt = []

    for ent in data:
        try:
            atemp = re.split('\s+|\t+', ent)
            if (len(atemp) > 3) and mtac.chkNumeric(atemp[1])  and mtac.chkNumeric(atemp[2])  and (int(atemp[4]) > 0):
                hbin.append(float(atemp[1]))
                hcnt.append(int(atemp[4]))
        except:
            pass

#
#--- checking 10 th bright position
#
    try:
        j = 0
        for i in  range(len(hbin)-1, 0, -1):
            if j == 9:
                val = i
                break
            else:
                if hcnt[i] > 0:                 #---- only when the value is larger than 0, record as count
                    j += 1

        return hbin[val]
    except:
        return 'I/INDEF'


#-----------------------------------------------------------------------------------------------------------
#-- print_stat: print out statistic                                                                      ---
#-----------------------------------------------------------------------------------------------------------

def print_stat(result, result2, year, month, outfile):

    """
    print out statistic
        input: result and result2 (output of dmstat)
               year, month
               outfile: the name of output file
    """

    f    = open(result, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

#
#--- extract mean, dev, min, and max
#
    for  ent in data:
        atemp = re.split('\s+|\t+', ent)

        m1 = re.search('mean', ent)
        m2 = re.search('min',  ent)
        m3 = re.search('max',  ent)
        m4 = re.search('sigma',ent)

        if m1 is not None:
            mean = atemp[1]

        if m2 is not None:
            min   = atemp[1]
            btemp = re.split('\(', ent)
            ctemp = re.split('\s+|\t+', btemp[1])
            min_pos = '(' + ctemp[1] + ',' + ctemp[2] + ')'

        if m3 is not None:
            max   = atemp[1]
            btemp = re.split('\(', ent)
            ctemp = re.split('\s+|\t+', btemp[1])
            max_pos = '(' + ctemp[1] + ',' + ctemp[2] + ')'

        if m4 is not None:
            dev = atemp[1]

#
#--- 10th brightest case
#

    f    = open(result2, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    for  ent in data:
        m = re.search('max', ent)
        if m is not None:
            atemp = re.split('\s+|\t+', ent)
            max2  = atemp[1]
            btemp = re.split('\(', ent)
            ctemp = re.split('\s+|\t+', btemp[1])
            max_pos2 = '(' + ctemp[1] + ',' + ctemp[2] + ')'

#
#--- print out data
#

    line = data_out + outfile
    f    = open(line, 'a')

    line = '%i\t%i\t'       % (year, month)
    f.write(line)
    line = '%5.6f\t%5.6f\t' % (float(mean), float(dev))
    f.write(line)
    line = '%5.1f\t%s\t'    % (float(min), min_pos)
    f.write(line)
    line = '%5.1f\t%s\t'    % (float(max), max_pos)
    f.write(line)
#    line = '%5.1f\t%s\n'    % (float(max2), max_pos2)
    line = '%5.1f\t%s\n'    % (0, '(0,0)')
    f.write(line)
    f.close()


#-----------------------------------------------------------------------------------------------------------
#--- acis_dose_extract_stat_data_month: driving fuction to compute statistics                            ---
#-----------------------------------------------------------------------------------------------------------


def acis_dose_extract_stat_data_month(year='NA', month='NA'):

    """
    driving fuction to compute statistics
    input: year and month
    """

    if year == 'NA' or month == 'NA':

        year  = raw_input("Year: ")
        year  = int(year)
        month = raw_input('Month: ')
        month = int(month)


    syear = str(year)
    smon  = str(month)
    if month < 10:
        smon = '0' + smon

#
#--- ACIS I2
#
    name1 = cum_dir + 'ACIS_07_1999_' + smon + '_' + syear + '_i2.fits.gz'
    name2 = mon_dir + 'ACIS_' + smon + '_' + syear + '_i2.fits.gz'

    line    = name1 + '[1:1024,1:256]'
    outfile = 'i_2_n_0_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,1:256]'
    outfile = 'i_2_n_0_dff_out'
    comp_stat(line, year, month, outfile)


    line    = name1 + '[1:1024,257:508]'            #--- the last few columns are dropped 
    outfile = 'i_2_n_1_acc_out'                     #--- to avoid bad pixles at the edge
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,257:508]'
    outfile = 'i_2_n_1_dff_out'
    comp_stat(line, year, month, outfile)


    line    = name1 + '[1:1024,513:768]'
    outfile = 'i_2_n_2_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,513:768]'
    outfile = 'i_2_n_2_dff_out'
    comp_stat(line, year, month, outfile)


    line    = name1 + '[1:1024,769:1020]'
    outfile = 'i_2_n_3_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,769:1020]'
    outfile = 'i_2_n_3_dff_out'
    comp_stat(line, year, month, outfile)

#
#--- ACIS I3
#
    name1 = cum_dir + 'ACIS_07_1999_' + smon + '_' + syear + '_i3.fits.gz'
    name2 = mon_dir + 'ACIS_' + smon + '_' + syear + '_i3.fits.gz'

    line    = name1 + '[1:1024,769:1020]'
    outfile = 'i_3_n_0_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,769:1020]'
    outfile = 'i_3_n_0_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[1:1024,513:768]'
    outfile = 'i_3_n_1_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,513:768]'
    outfile = 'i_3_n_1_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[1:1024,257:508]'
    outfile = 'i_3_n_2_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,257:508]'
    outfile = 'i_3_n_2_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[1:1024,1:256]'
    outfile = 'i_3_n_3_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:1024,1:256]'
    outfile = 'i_3_n_3_dff_out'
    comp_stat(line, year, month, outfile)

#
#--- ACIS S2
#
    name1 = cum_dir + 'ACIS_07_1999_' + smon + '_' + syear + '_s2.fits.gz'
    name2 = mon_dir + 'ACIS_' + smon + '_' + syear + '_s2.fits.gz'

    line    = name1 + '[1:256,1:1020]'
    outfile = 's_2_n_0_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:256,1:1020]'
    outfile = 's_2_n_0_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[257:508,1:1020]'
    outfile = 's_2_n_1_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[257:508,1:1020]'
    outfile = 's_2_n_1_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[513:768,1:1020]'
    outfile = 's_2_n_2_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[513:768,1:1020]'
    outfile = 's_2_n_2_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[769:1024,1:1020]'
    outfile = 's_2_n_3_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[769:1024,1:1020]'
    outfile = 's_2_n_3_dff_out'
    comp_stat(line, year, month, outfile)

#
#--- ACIS S3
#
    name1 = cum_dir + 'ACIS_07_1999_' + smon + '_' + syear + '_s3.fits.gz'
    name2 = mon_dir + 'ACIS_' + smon + '_' + syear + '_s3.fits.gz'

    line    = name1 + '[1:256,1:1020]'
    outfile = 's_3_n_0_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[1:256,1:1020]'
    outfile = 's_3_n_0_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[257:508,1:1020]'
    outfile = 's_3_n_1_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[257:508,1:1020]'
    outfile = 's_3_n_1_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[513:768,1:1020]'
    outfile = 's_3_n_2_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[513:768,1:1020]'
    outfile = 's_3_n_2_dff_out'
    comp_stat(line, year, month, outfile)

    line    = name1 + '[769:1024,1:1020]'
    outfile = 's_3_n_3_acc_out'
    comp_stat(line, year, month, outfile)

    line    = name2 + '[769:1024,1:1020]'
    outfile = 's_3_n_3_dff_out'
    comp_stat(line, year, month, outfile)




#--------------------------------------------------------------------------------------------------------

if __name__ == '__main__':
    
    acis_dose_extract_stat_data_month()
