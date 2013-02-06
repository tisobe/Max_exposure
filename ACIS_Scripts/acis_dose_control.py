#!/usr/local/bin/python2.6

#########################################################################################
#                                                                                       #
#       acis_dose_control.py: monthly acis dose update control script                   #
#                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                       #
#       last updated: Feb 06, 2013                                                      #
#                                                                                       #
#########################################################################################

import sys
import os
import string
import re
import fnmatch

#
#--- reading directory list
#

path = '/data/mta/Script/Exposure/house_keeping/acis_dir_list'
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
#--- Exposure related funcions shared
#

import exposureFunctions            as expf
import acis_dose_get_data           as getd
import acis_create_cumulative       as cuml
import acis_compute_stat            as astat
import acis_dose_plot_exposure_stat as aplot
import acis_dose_make_data_html     as ahtml
import acis_dose_monthly_report     as arport
import acis_dose_create_image       as aimg


#-----------------------------------------------------------------------------------------------------------
#-- acis_dose_control: monthly acis dose update contorl script                                           ---
#-----------------------------------------------------------------------------------------------------------

def acis_dose_control(year = 'NA', month = 'NA'):

    """
    monthly acis dose update control script
    input: optional year and month
    """

    if year == 'NA' or month == 'NA':

        (year, mon, day, hours, min, sec, weekday, yday, dst) = tcnv.currentTime('Local')

        month = mon -1
        if month < 1:
            month = 12
            year -= 1

        syear = str(year)
        smon  = str(month)
        if month < 10:
            smon = '0' + smon

#
#--- extract data
#
    getd.acis_dose_get_data(year, month, year, month)
#
#--- create cumulative data and sectioned data for bot month and cumulative data
#
    file = 'ACIS_' + smon + '_' + syear + '.fits'
    file2= 'ACIS_' + smon + '_' + syear + '.fits.gz'

    chk = 0
    for test in os.listdir('./'):
        if fnmatch.fnmatch(test, file2):
            chk = 1
            break

    if chk == 0:
       cuml.acis_create_cumulative(file)
       pass
    else:
       pass
       cuml.acis_create_cumulative(file2)
#
#--- compute statistics
#
    astat.acis_dose_extract_stat_data_month(year, month)
#
#--- plot data
#
    aplot.acis_dose_plot_exposure_stat(clean='Yes')
#
#--- create images (you need to use ds9 to create a better image)
#
    aimg.create_acis_maps(year, month)
#
#--- update html pages
#
    ahtml.acis_dose_make_data_html()

#
#--- print monthly output
#
    arport.acis_dose_monthly_report()



#--------------------------------------------------------------------------------------------------------

if __name__ == '__main__':
    
    acis_dose_control()


