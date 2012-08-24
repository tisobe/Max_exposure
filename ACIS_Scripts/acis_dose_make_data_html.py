#!/usr/local/bin/python2.6

#########################################################################################
#                                                                                       #
#       acis_dose_make_data_html.py: create html pages for ACIS CCDs                    #
#                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                       #
#       last update: Jul 10, 2012                                                       #
#                                                                                       #
#########################################################################################

import sys
import os
import string
import re
import copy

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
#--- append path to a privte folder
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

import exposureFunctions as expf

#------------------------------------------------------------------------------------------------------------------------
#--- acis_dose_make_data_html: read hrc database, and plot history of exposure                                     ---
#------------------------------------------------------------------------------------------------------------------------

def acis_dose_make_data_html(indir = 'NA', outdir = 'NA'):

    """
    read data and create html pages
    input: indir, outdir, both are optional
    """
#
#--- setting indir and outdir if not given
#
    if indir   == 'NA':
        indir   = data_out

    if outdir  == 'NA':
        outdir  = data_out

#
#--- read data
#
    for ccd in ('i_2', 'i_3', 's_2', 's_3'):
        for sec in range(0, 4):

            inst = ccd + '_n_' + str(sec)


            date     = []
            year     = []
            month    = []
            mean_acc = []
            std_acc  = []
            min_acc  = []
            min_apos = []
            max_acc  = []
            max_apos = []
            m10_acc  = []
            m10_apos = []
            mean_dff = []
            std_dff  = []
            min_dff  = []
            min_dpos = []
            max_dff  = []
            max_dpos = []
            m10_dff  = []
            m10_dpos = []
        
            expf.readExpData(indir, inst, date, year,month,mean_acc,std_acc,min_acc,min_apos,  max_acc,max_apos,m10_acc, \
                      m10_apos,mean_dff,std_dff,min_dff, min_dpos,max_dff,max_dpos,m10_dff,m10_dpos)

#
#--- write html page
#
            write_html(ccd, sec, year,month,mean_acc,std_acc,min_acc,min_apos,  max_acc,max_apos,m10_acc, \
                                 m10_apos,mean_dff,std_dff,min_dff, min_dpos,max_dff,max_dpos,m10_dff,m10_dpos)

            out_name = outdir + inst + '.html'
            cmd = 'mv acis.html ' + out_name
            os.system(cmd)

#------------------------------------------------------------------------------------------------------------------------
#--    write_html: write a html page                                                                                   --
#------------------------------------------------------------------------------------------------------------------------

def write_html(ccd, sec, year,month,mean_acc,std_acc,min_acc,min_apos,  max_acc,max_apos,m10_acc, \
                m10_apos,mean_dff,std_dff,min_dff, min_dpos,max_dff,max_dpos,m10_dff,m10_dpos):

    """
    write a html page:
    input: ccd, sec, year,month,mean_acc,std_acc,min_acc,min_apos,  max_acc,max_apos,m10_acc
           m10_apos,mean_dff,std_dff,min_dff, min_dpos,max_dff,max_dpos,m10_dff,m10_dpos
    """

    (lyear, lmon, lday, lhours, lmin, lsec, lweekday, lyday, dst) = tcnv.currentTime('Local')

    f = open('acis.html', 'w')

#
#--- this is a html 5 document
#
    f.write('<!DOCTYPE html>\n')
    f.write('<html>\n')
    f.write('<head>\n')
    line = '<title>ACIS ' + ccd.upper() + ' Section ' + str(sec) + ' History Data</title>\n'
    f.write(line)
    f.write('<body text="#FFFFFF" bgcolor="#000000" link="#00CCFF vlink="yellow" alink="yellow"> \n')
#
#--- css style sheet
#
    f.write('<style type="text/css">\n')
    f.write('td {text-align:center}\n')
    f.write('</style>\n')
    
    f.write('</head>\n')


    line = '<br /><h3> Last Update: ' + str(lmon) + '/' + str(lday) + ' / ' +  str(lyear) + '</h3>\n'
    f.write(line)
    f.write('<table border=1 cellspacing=3 cellpadding=3>\n')

    header_write(f)

    for i in range(0, len(year)):
        f.write('<tr>\n')
        line =        '<td>' + str(year[i])     + '</td>\t'
        line = line + '<td>' + str(month[i])    + '</td>\t'
        line = line + '<td>' + str(mean_dff[i]) + '</td>\t'
        line = line + '<td>' + str(std_dff[i])  + '</td>\t'
        line = line + '<td>' + str(min_dff[i])  + '</td>\t'
        line = line + '<td>' + str(min_dpos[i]) + '</td>\t'
        line = line + '<td>' + str(max_dff[i])  + '</td>\t'
        line = line + '<td>' + str(max_dpos[i]) + '</td>\t'
        line = line + '<td>' + str(m10_dff[i])  + '</td>\t'
        line = line + '<td>' + str(m10_dpos[i]) + '</td>\n'
        f.write(line)
        syear = str(year[i])
        smon  = str(month[i])
        if month[i] < 10:
            smon = '0' + smon
        file = 'ACIS_' + smon + '_' + syear + '_' + ccd 

        line = '<td><a href="http://cxc.harvard.edu/mta_days/mta_max_exp/Month/' + file + '.fits.gz">fits</a>/</td>\n'
        f.write(line)
        line = '<td><a href="http://cxc.harvard.edu/mta_days/mta_max_exp/Image/' + file + '.png">fits</a>/</td>\n\n'
        f.write(line)
#
#--- put header every new year so that we can read data easier
#
        if month[i] % 12 == 0 and i != (len(year)-1):
            header_write(f)
            f.write('\n')

    f.write('</table>\n\n')
    f.write('<br /><br /><hr /><br />\n')

    line = '<br /><strong style="font-size:105%;float:right">Last Update: ' + smon + '/' + str(lday) + '/' + str(lyear) + '</strong>\n'
    f.write(line)

    line = 'If you have any questions about this page, contact <a href="mailto:isobe@haed.cfa.harvad.edu">isobe@haed.cfa.harvad.edu.\n'
    f.write(line)
    f.write('</body>\n')
    f.write('</html>\n')

    f.close()


#--------------------------------------------------------------------------------------------------------
#-- header_write: writing header part of html                                                         ---
#--------------------------------------------------------------------------------------------------------

def header_write(f):    

    """
    writing a header part of html
    input: f --- pipe to the file
    """

    f.write('<trstyle="color:yellow">\n')
    f.write('<td>&#160</td><td>&#160</td>\n')
    f.write('<td colspan=10>Monlthy</td>\n')
    f.write('<td colspan=10>Cumulative</td>\n')
    f.write('</tr><tr>\n')

    f.write('<th>Month</th>\n')
    f.write('<th>Mean</th>\n')
    f.write('<th>SD</th>\n')
    f.write('<th>Min</th>\n')
    f.write('<th>Min Position</th>\n')
    f.write('<th>Max</th>\n')
    f.write('<th>Max Position</th>\n')
    f.write('<th>10th Bright</th>\n')
    f.write('<th>10th Bright  Position</th>\n')
    f.write('<th>Data</th>\n')
    f.write('<th>Map</th>\n')

    f.write('<th>Mean</th>\n')
    f.write('<th>SD</th>\n')
    f.write('<th>Min</th>\n')
    f.write('<th>Min Position</th>\n')
    f.write('<th>Max</th>\n')
    f.write('<th>Max Position</th>\n')
    f.write('<th>10th Bright</th>\n')
    f.write('<th>10th Bright  Position</th>\n')
    f.write('<th>Data</th>\n')
    f.write('<th>Map</th>\n')
    f.write('</tr>\n')



#--------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------

def update_plt_html_date():

    """
    update html pages for plots; just replacing date
    no input, but get the list from plot_dir
    """
    (lyear, lmon, lday, lhours, lmin, lsec, lweekday, lyday, dst) = tcnv.currentTime('Local')

    line = '<br><h3> Last Update: ' + str(lmon) + '/' + str(lday) + '/' + str(lyear) + '</h3>'


    cmd  = 'ls ' + plot_dir + '*html>./ztemp' 
    os.system(cmd)
    f    = open('./ztemp', 'r')
    data = [line.strip() for line in f.readlines()]
    f.close()
    os.system('rm ./ztemp')

    for ent in data:
        f    = open(ent, 'r')
        hdat = [line.strip() for line in f.readlines()]
        f.close()
        f    = open('./temp', 'w')

        for oline in hdat:
            m = re.search('Last Update', oline)
            if m is not None:
                f.write(line)
                f.write('\n')

            else:
                f.write(oline)
                f.write('\n')

        f.close() 

        cmd = 'mv ./temp ' + ent
        os.system(cmd)












#--------------------------------------------------------------------------------------------------------

if __name__ == '__main__':

    acis_dose_make_data_html(indir = 'NA', outdir = 'NA')
