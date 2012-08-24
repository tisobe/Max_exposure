#!/usr/local/bin/python2.6

#################################################################################################
#                                                                                               #
#       hrc_dose_extract_stat_data_month.py: extract statistics from HRC S and I files          #
#                               output is avg, min, max,                                        #
#                                                                                               #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                               #
#                                                                                               #
#       last update: Jun 22, 2012                                                               #
#                                                                                               #
#################################################################################################

import sys
import os
import string
import re

#
#--- reading directory list
#

path = '/data/mta/Script/Exposure/house_keeping2/hrc_dir_list'
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

sys.path.append(bin_dir)
sys.path.append(mta_dir)

#
#--- converTimeFormat contains MTA time conversion routines
#
import convertTimeFormat    as tcnv

#
#--- mta common functions
#

import mta_common_functions as mtac

#
#--- Exposure related funcions shared
#

import exposureFunctions as expf


#--------------------------------------------------------------------------------------------------------------
#--- comp_stat: compute statistics for the hrc image and print out the result                                --
#--------------------------------------------------------------------------------------------------------------

def comp_stat(file, year, month, out):

    """
    compute statistics for the hrc image and print out the result: input: hrc image file, year, month, output file name.
    """

    chk = mtac.chkFile(file)        #--- checking whether the file exists

    if chk > 0:
#
#--- to avoid getting min value from the outside of the frame edge of a CCD, set threshold
#
        cmd = 'dmimgthresh infile=' + file + ' outfile=zcut.fits  cut="0:1.e10" value=0 clobber=yes'
        os.system(cmd)
        cmd = 'dmstat  infile=zcut.fits  centroid=no > ./result'
        os.system(cmd)
        os.system('rm zcut.fits')

        f    = open('./result', 'r')
        data = [line.strip() for line in f.readlines()]
        f.close()
        
        val = 'NA'
        for ent in data:
            ent.lstrip()
            m = re.search('mean', ent)
            if m is not None:
                atemp = re.split('\s+|\t', ent)
                val   = atemp[1]
                break

        if val != 'NA':
            upper = find10th(file)
            if upper == 'I/INDEF':
                cmd = 'dmstat  infile=' + file + '  centroid=no > ./result2'
                os.system(cmd)
                
            else:
                cmd = 'dmimgthresh infile=' + file + ' outfile=zcut.fits  cut="0:' + upper + '" value=0 clobber=yes'
                os.system(cmd)
                cmd = 'dmstat  infile=zcut.fits  centroid=no > ./result2'
                os.system(cmd)
                os.system('rm ./zcut.fits')

            (mean,  dev,  min,  max , min_pos_x,  min_pos_y,  max_pos_x,  max_pos_y)  = readStat('result')
            (mean2, dev2, min2, max2, min_pos_x2, min_pos_y2, max_pos_x2, max_pos_y2) = readStat('result2')
            os.system('rm result result2')

        else:
            (mean,  dev,  min,  max , min_pos_x,  min_pos_y,  max_pos_x,  max_pos_y)  = ('NA','NA','NA','NA','NA','NA','NA','NA')

    else:
        (mean,  dev,  min,  max , min_pos_x,  min_pos_y,  max_pos_x,  max_pos_y)  = ('NA','NA','NA','NA','NA','NA','NA','NA')
        (mean2, dev2, min2, max2, min_pos_x2, min_pos_y2, max_pos_x2, max_pos_y2) = ('NA','NA','NA','NA','NA','NA','NA','NA')


#
#--- print out the results
#

    chk = mtac.chkFile(out)        #--- checking whether the file exists

    if chk > 0:
        f = open(out, 'a')
    else:
        f = open(out, 'w')

    line = '%d\t%d\t' % (year, month)
    f.write(line)

    if mean == 'NA' or mean2 == 'NA':
        f.write('NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\n')
    else:
        line = '%5.6f\t%5.6f\t%5.1f\t(%d,%d)\t' % (mean, dev, min, min_pos_x, min_pos_y)
        f.write(line)
        line = '%5.1f\t(%d,%d)\t%5.1f\t(%d,%d)\n' % (max, max_pos_x, max_pos_y, max2, max_pos_x2, max_pos_y2)
        f.write(line)

    f.close()


#--------------------------------------------------------------------------------------------------------------
#--- readStat:  dmstat output file and extract data values.                                                 ---
#--------------------------------------------------------------------------------------------------------------

def readStat(file):

    """
    read dmstat output file and extract data values. 
        input: file. output: (mean, dev, min, max, min_pos_x, min_pos_y, max_pos_x, max_pos_y)
    """

    mean      = 'NA'
    dev       = 'NA'
    min       = 'NA'
    max       = 'NA'
    min_pos_x = 'NA'
    min_pos_y = 'NA'
    max_pos_x = 'NA'
    max_pos_y = 'NA'

    f    = open(file, 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    for ent in data:
        ent.lstrip()
        atemp = re.split('\s+|\t+', ent)
        m1 = re.search('mean',  ent)
        m2 = re.search('sigma', ent)
        m3 = re.search('min',   ent)
        m4 = re.search('max',   ent)

        if m1 is not None:
            mean = float(atemp[1])
        elif m2 is not None:
            dev  = float(atemp[1])
        elif m3 is not None:
            min  = float(atemp[1])
            btemp = re.split('\(', ent)
            ctemp = re.split('\s+|\t+', btemp[1])
            min_pos_x = float(ctemp[1])
            min_pos_y = float(ctemp[2])
        elif m4 is not None:
            max  = float(atemp[1])
            btemp = re.split('\(', ent)
            ctemp = re.split('\s+|\t+', btemp[1])
            max_pos_x = float(ctemp[1])
            max_pos_y = float(ctemp[2])

    return (mean, dev, min, max, min_pos_x, min_pos_y, max_pos_x, max_pos_y)



#--------------------------------------------------------------------------------------------------------------
#--- find10th: finding 10th brightest pisxel position                                                       ---
#--------------------------------------------------------------------------------------------------------------

def find10th(file):

    """
    finding 10th brightest pisxel position: input file name
    """

    cmd = 'dmimghist infile=' + file + ' outfile=outfile.fits hist=1::1 strict=yes clobber=yes'
    os.system(cmd)
    cmd = 'dmlist infile=outfile.fits opt=data > zout'
    os.system(cmd)
    os.system('rm outfile.fits')
    
    f    = open('./zout', 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()

    hbin = []
    hcnt = []
    tot  = 0
    for ent in data:
        ent.lstrip()
        atemp = re.split('\s+|\t+', ent)
        if atemp[0].isdigit():
            hbin.append(atemp[1])
            hcnt.append(atemp[3])

#
#--- checking 10 th bright position
#

    try:
        j = 0
        for i in range(len(hbin)-1, 0, -1):
            if j == 9:
                val = i
                break
            else:
                if hcnt[i] > 0:
                    j += 1

        upper = hbin[val]
    except:
        upper  = 'I/INDEF'

    return upper


        

#--------------------------------------------------------------------------------------------------------------
#--- hrc_dose_extract_stat_data_month: compute HRC statistics                                               ---
#--------------------------------------------------------------------------------------------------------------

def hrc_dose_extract_stat_data_month(year='NA', month='NA'):

    """
    compute HRC statistics: input year, month
    """

    if year == 'NA' or month == 'NA':
        year  = raw_input('Year: ')
        month = raw_input('Month: ')
    
    year  = int(year)
    month = int(month)

    syear  = str(year)
    smonth = str(month)
    if month < 10:
        smonth = '0' + smonth

#
#--- center exposure map stat
#
    file = cum_dir_hrc  + '/HRCS_08_1999_' + smonth + '_' + syear + '.fits.gz'
    out  = data_out + '/hrcs_acc_out'
    comp_stat(file, year, month, out)

    file = mon_dir_hrc + '/HRCS_'         + smonth + '_' + syear + '.fits.gz'
    out  = data_out + '/hrcs_dff_out'
    comp_stat(file, year, month, out)

    file = cum_dir_hrc  + '/HRCI_08_1999_' + smonth + '_' + syear + '.fits.gz'
    out  = data_out + '/hrci_acc_out'
    comp_stat(file, year, month, out)

    file = mon_dir_hrc + '/HRCI_'         + smonth + '_' + syear + '.fits.gz'
    out  = data_out + '/hrci_dff_out'
    comp_stat(file, year, month, out)

#
#--- full exposure map stat
#

    for i in range(0,10):
        file = cum_dir_hrc_full +  '/HRCS_09_1999_' + smonth + '_' + syear + '_'+ str(i) +  '.fits.gz'
        out  = data_out_hrc + '/hrcs_' + str(i) + '_acc'
        comp_stat(file, year, month, out)

        file = mon_dir_hrc_full +  '/HRCS_' + smonth + '_' + syear + '_'+ str(i) +  '.fits.gz'
        out  = data_out_hrc + '/hrcs_' + str(i) + '_dff'
        comp_stat(file, year, month, out)


    for i in range(0,9):
        file = cum_dir_hrc_full +  '/HRCI_09_1999_' + smonth + '_' + syear + '_'+ str(i) +  '.fits.gz'
        out  = data_out_hrc + '/hrci_' + str(i) + '_acc'
        comp_stat(file, year, month, out)

        file = mon_dir_hrc_full +  '/HRCI_' + smonth + '_' + syear + '_'+ str(i) +  '.fits.gz'
        out  = data_out_hrc + '/hrci_' + str(i) + '_dff'
        comp_stat(file, year, month, out)


#--------------------------------------------------------------------------------------------------------

if __name__ == '__main__':

    hrc_dose_extract_stat_data_month()
