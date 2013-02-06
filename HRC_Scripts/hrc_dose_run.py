#!/usr/local/bin/python2.6

#########################################################################################
#                                                                                       #
#       hrc_dose_run.py: run all required scripts to create HRC data/images             #
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

#
#--- reading directory list
#

path = '/data/mta/Script/Exposure/house_keeping/hrc_dir_list'
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
#--- import HRC related scripts/functions
#

import convertTimeFormat                as tcnv                 #--- MTA time conversion routines
import exposureFunctions                as expf                 #--- exposure related functions
import hrc_dose_get_data_full_rage      as hgdata               #--- getting data
import hrc_dose_extract_stat_data_month as hstat                #--- hrc statistics
import hrc_dose_make_data_html          as hhtml                #--- html related
import hrc_dose_plot_exposure_stat      as hplot                #--- plot related
import hrc_dose_create_image            as himg                 #--- image creation
import hrc_dose_plot_monthly_report     as monthly              #--- plotting monthly report plot

#--------------------------------------------------------------------------------------------------------------
#--- hrc_dose_run: run all needed HRC scripts to extract data and create images                             ---
#--------------------------------------------------------------------------------------------------------------

def hrc_dose_run(year='NA', month='NA'):

    """
    run all needed HRC scripts to extract data and create images  
    """


#
#--- if year and month are given, get that year and month for data extraction
#
    if year != 'NA' and str(year).isdigit() and str(month).isidigit():
        lyear  = int(year)
        lmonth = int(month)

#
#--- if year and month are not given, use a month before the current year/month
#
    else:
        (year, month, day, hours, min, sec, weekday, yday, dst) = tcnv.currentTime('Local')

        lyear  = year
        lmonth = month - 1
        if lmonth < 1:
            lmonth = 12
            lyear -= 1

    hgdata.hrc_dose_get_data(lyear, lmonth, lyear, lmonth)          #---- extracting data
    hstat.hrc_dose_extract_stat_data_month(lyear, lmonth)           #---- computing statistics
    hhtml.hrc_dose_make_data_html()                                 #---- creating html pages
    hplot.hrc_dose_plot_exposure_stat()                             #---- plotting histories
    himg.create_hrc_maps(lyear, lmonth)                             #---- creating map images
    monthly.hrc_dose_plot_monthly_report()                          #---- plotting monthly report trend

#
#--- change the group to mtagroup
#
    cmd = 'chgrp mtagroup ' + hrc_full_data + '*/*'
    os.system(cmd)
    cmd = 'chgrp mtagroup ' + web_dir + 'HRC/*'
    os.system(cmd)
    cmd = 'chgrp mtagroup ' + web_dir + 'HRC/*/*'
    os.system(cmd)

#
#--- copying data to mays ---- not used; data are now directly deposite to mays
#
    syear = str(lyear)
    smon  = str(lmonth)
    if lmonth  < 10:
        smon = '0' + smon

    new_data = '*' + smon + '_' + syear + '*' 

    cmd = 'cp ' + mon_dir_hrc_full +  new_data + ' ' +  mays_dir + 'Month_hrc/.'
    os.system(cmd)
    cmd = 'cp ' + cum_dir_hrc_full +  new_data + ' ' +  mays_dir + 'Cumulative_hrc/.'
    os.system(cmd)



#--------------------------------------------------------------------------------------------------------

if __name__ == '__main__':
    
    hrc_dose_run()

