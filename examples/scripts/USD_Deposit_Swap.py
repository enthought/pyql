# -*- coding: utf-8 -*-
# <nbformat>3</nbformat>

# <markdowncell>

# USD Deposit and Swap Rates
# ==========================
# 
# This notebook shows how to download and process a curve of US deposit and swap rates. The data comes from the US Federal Reserve Board, and is published daily as a data set named 'Table H15'. 

# <markdowncell>

# Utility functions
# -----------------
# 
# The data is obtained from the site www.federalreserve.gov. Time series can be downloaded from a web browser. They can also be downloaded programmatically. The site provides directions on how to construct the URL corresponding to each particular data set. In the example below, the URL is specific to the H15 table.

# <codecell>

import os, urllib, datetime, pandas
import numpy as np
import pylab as pl
import math

from pandas.io.parsers import read_csv
from datetime import date

import StringIO

def get_frb_url(dtStart, dtEnd):
    """
    Federal Reserve Board URL
    Construct this URL at 'http://www.federalreserve.gov/datadownload
    """
    
    url = 'http://www.federalreserve.gov/datadownload/Output.aspx?rel=H15&series=8f47c9df920bbb475f402efa44f35c29&lastObs=&from=%s&to=%s&filetype=csv&label=include&layout=seriescolumn' % (dtStart.strftime('%m/%d/%Y'), dtEnd.strftime('%m/%d/%Y'))
    return url   

# <markdowncell>

# Download and plot the data
# --------------------------

# <codecell>

if __name__ == '__main__':

    dtObs = date(2012,6,28)
    url = get_frb_url(dtStart=dtObs, dtEnd=dtObs)
    frb_site = urllib.urlopen(url)
    
    buff = StringIO.StringIO(frb_site.read().strip())
    
    # simpler labels and maturities in years

    columns_dic = {"RIFLDIY01_N.B":('Swap1Y', 1),
               "RIFLDIY02_N.B":('Swap2Y', 2),
               "RIFLDIY03_N.B":('Swap3Y', 3),
               "RIFLDIY04_N.B":('Swap4Y', 4),
               "RIFLDIY05_N.B":('Swap5Y', 5),
               "RIFLDIY07_N.B":('Swap7Y', 7),
               "RIFLDIY10_N.B":('Swap10Y', 10),
               "RIFLDIY30_N.B":('Swap30Y', 30),
               "RILSPDEPM01_N.B":('Libor1M', 1.0/12),
               "RILSPDEPM03_N.B":('Libor3M', 3.0/12),
               "RILSPDEPM06_N.B":('Libor6M', 6.0/12)}

    # convert buffer to data frame
    df_libor = read_csv(buff, sep=',', header=True,
                    index_col=0, parse_dates=True,
                    skiprows=[0,1,2,3,4]).transpose()

    # rename rows and columns with better names
    col_name_dic = {k: columns_dic[k][0] for k in columns_dic.keys()}
    df_libor = df_libor.rename(index=col_name_dic,
                               columns={df_libor.columns[0]:'Rate'})
    
    # dictionary of maturities
    col_mat_dic = {columns_dic[k][0]:columns_dic[k][1] \
                   for k in columns_dic.keys()}

    # add maturity column
    df_libor['Maturity'] = [col_mat_dic[k] for k in df_libor.index]
    
    # ... and sort by increasing maturity
    df_libor = df_libor.sort_index(by='Maturity')

    print df_libor
    
    pl.plot(df_libor['Maturity'], df_libor['Rate'])
    pl.xlabel('Maturity (Yr)')
    pl.ylabel('Deposit/Libor Rate')
    pl.title('Libor Deposit and Swap Rates (%s) \n from Table H15 at www.federalreserve.gov' % dtObs.strftime('%d-%m-%Y'))
    show()

