#!/usr/local/bin/python2.6

#########################################################################################
#                                                                                       #
#       hrc_dose_plot_exposure_stat.py:  plotting trendings for monthly report          #
#                                                                                       #
#       author: t. isobe (tisobe@cfa.harvard.edu)                                       #
#                                                                                       #
#       last update: Feb 06, 2013                                                       #
#                                                                                       #
#########################################################################################


import sys
import os
import string
import re
import copy

#
#--- pylab plotting routine related modules
#

from pylab import *
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import matplotlib.lines as lines


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
#--- append path to a privte folder
#

sys.path.append(bin_dir)
sys.path.append(mta_dir)

#
#--- converTimeFormat contains MTA time conversion routines
#
import convertTimeFormat as tcnv

#
#--- Exposure related funcions shared
#

import exposureFunctions as expf

#------------------------------------------------------------------------------------------------------------------------
#--- hrc_dose_plot_monthly_report: read hrc database, and plot history of exposure  for monthly report                ---
#------------------------------------------------------------------------------------------------------------------------

def hrc_dose_plot_monthly_report(indir = 'NA', outdir = 'NA'):

    'read hrc database, and plot history of exposure. input: data directory path, output directory path '
#
#--- setting indir and outdir if not given
#
    if indir   == 'NA':
        indir   = data_out

    if outdir  == 'NA':
        outdir  = img_dir

#
#--- read HRC I data
#
        idate     = []
        iyear     = []
        imonth    = []
        imean_acc = []
        istd_acc  = []
        imin_acc  = []
        imin_apos = []
        imax_acc  = []
        imax_apos = []
        im10_acc  = []
        im10_apos = []
        imean_dff = []
        istd_dff  = []
        imin_dff  = []
        imin_dpos = []
        imax_dff  = []
        imax_dpos = []
        im10_dff  = []
        im10_dpos = []

        expf.readExpData(indir, 'hrci' , idate, iyear,imonth,imean_acc,istd_acc,imin_acc,imin_apos,  imax_acc,imax_apos,im10_acc, \
                          im10_apos,imean_dff,istd_dff,imin_dff, imin_dpos,imax_dff,imax_dpos,im10_dff,im10_dpos)


#
#--- read HRC S data
#
        sdate     = []
        syear     = []
        smonth    = []
        smean_acc = []
        sstd_acc  = []
        smin_acc  = []
        smin_apos = []
        smax_acc  = []
        smax_apos = []
        sm10_acc  = []
        sm10_apos = []
        smean_dff = []
        sstd_dff  = []
        smin_dff  = []
        smin_dpos = []
        smax_dff  = []
        smax_dpos = []
        sm10_dff  = []
        sm10_dpos = []

        expf.readExpData(indir, 'hrcs', sdate, syear,smonth,smean_acc,sstd_acc,smin_acc,smin_apos,  smax_acc,smax_apos,sm10_acc, \
                          sm10_apos,smean_dff,sstd_dff,smin_dff, smin_dpos,smax_dff,smax_dpos,sm10_dff,sm10_dpos)

#
#--- plot data
#
        plot_max_dose(idate, imax_acc, smax_acc)

#
#--- move the plot  to img directory
#

        cmd = 'mv hrc_max_exp.gif ' + outdir
        os.system(cmd)

#------------------------------------------------------------------------------------------------------------------------
#--- plot_max_dose: plot hrc i and hrc s max exposure plots                                                            --
#------------------------------------------------------------------------------------------------------------------------

def plot_max_dose(date, hrci_max, hrcs_max):

    """
    plot hrc i and hrc s max exposure plots
    input: time, hrc i max cumurative exposure data, hrc s max cumurative exposure data
    """

    plt.close('all')

#
#---- set a few parameters
#

    mpl.rcParams['font.size'] = 16
    mpl.rcParams['font.style'] = 'bold'
    mpl.rcParams['axes.linewidth'] = 2.0
    props = font_manager.FontProperties(size=14)
    plt.subplots_adjust(hspace=0.05)
    plt.subplots_adjust(wspace=0.12)

#
#--- HRC I
#
    ax1 = plt.subplot(2,1,1)
    plot_panel(date, hrci_max, 'HRC-I', ax1, ymin = 250)
#
#--- HRC S
#
    ax2 = plt.subplot(2,1,2)
    plot_panel(date, hrcs_max, 'HRC-S', ax2, ymin = 1400)
#
#--- plot x axis tick label only at the bottom ones
#
    for ax in ax1, ax2:
        if ax != ax2:
            for label in ax.get_xticklabels():
                label.set_visible(False)
        else:
            pass

#
#--- putting axis names
#
        ax1.set_ylabel('Counts')
        ax2.set_ylabel('Counts')
        ax2.set_xlabel('Year')
#
#--- set the size of the plotting area in inch (width: 10.0in, height 5.0in)
#   
    fig = matplotlib.pyplot.gcf()
    fig.set_size_inches(10.0, 8.0)
#
#--- save the plot in png format and then convert to gif
#   
    plt.savefig('hrc_max_exp.png', format='png', dpi=100)

    cmd = 'convert hrc_max_exp.png hrc_max_exp.gif'                     #---- convert is unix command to change img format
    os.system(cmd)
    os.system('rm hrc_max_exp.png')

    plt.close('all')



#------------------------------------------------------------------------------------------------------------------------
#---   plot_panel: plotting each panel for a given "ax"                                                               ---
#------------------------------------------------------------------------------------------------------------------------

def plot_panel(x, y, label, ax, ymin = 'NA', ymax = 'NA'):

    'plotting each panel for a given "ax". Input: x, y, label, ax (designation of the plot), ymin ="NA" ymax = "NA". '

#
#--- x axis setting: here we assume that x is already sorted
#
    xmin = x[0]
    xmax = x[len(x) -1]
    diff = xmax - xmin
    xmin = xmin - 0.05 * diff
    xmax = xmax + 0.05 * diff
    xbot = xmin + 0.05 * diff
#
#--- y axis setting
#
    tymin = 1e8
    tymax = 1e-8
    for i in range(0, len(y)):
        if y[i] > tymax: 
            tymax = y[i]
        if y[i] < tymin:
            tymin = y[i]

    if ymin == 'NA':
        ymin = tymin

    if ymax == 'NA':
        ymax = tymax

#
#--- for the case,  ymin == ymax, 
#
    if ymin == ymax:
        ymax += 1

    diff = ymax - ymin
    ymin = ymin - 0.01 * diff

    if ymin < 0:
        ymin = 0

    ymax = ymax + 0.1 * diff
    ytop = ymax - 0.12 * diff

#
#--- setting panel 
#

    ax.set_autoscale_on(False)         #---- these three may not be needed for the new pylab, but 
    ax.set_xbound(xmin,xmax)           #---- they are necessary for the older version to set

    ax.set_xlim(xmin=xmin, xmax=xmax, auto=False)
    ax.set_ylim(ymin=ymin, ymax=ymax, auto=False)

#
#--- plot line
#
    plt.plot(x, y, color='blue',   lw=3, marker='+', markersize=2.0)

    plt.text(xbot, ytop, label)







#--------------------------------------------------------------------------------------------------------

if __name__ == '__main__':

    hrc_dose_plot_monthly_report()
