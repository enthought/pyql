# -*- coding: utf-8 -*-
# <nbformat>3</nbformat>

# <markdowncell>

# Time Series of US Deposit and Swap Rates
# ========================================
# 
# This notebook demonstrates how to download time series of USD deposit and swap rates from the US Federal Reserve Board web site. 
# 
# The data is obtained from the site www.federalreserve.gov. The time series can be downloaded from a web browser, but they can also be downloaded programmatically. The site provides directions on how to construct the URL corresponding to each particular data set. In the example below, the URL is specific to the H15 table, with all available deposit and swap rates included.
# 
# In this notebook, we download 11 years of daily data, from January 2000 to December 2011. The data is stored in a pandas DataFrame for further processing.

# <codecell>

import os, urllib, datetime, pandas
import numpy as np
import math

from pandas.io.parsers import read_csv
from datetime import date

def get_frb_url(dtStart, dtEnd):
    """
    Federal Reserve Board URL
    Construct this URL at 'http://www.federalreserve.gov/datadownload
    """
    
    url = 'http://www.federalreserve.gov/datadownload/Output.aspx?rel=H15&series=8f47c9df920bbb475f402efa44f35c29&lastObs=&from=%s&to=%s&filetype=csv&label=include&layout=seriescolumn' % (dtStart.strftime('%m/%d/%Y'), dtEnd.strftime('%m/%d/%Y'))
    return url

def dataconverter(s):
    """
    The FRB data file has 
    - numeric cells
    - empty cells
    - cells with 'NC' or 'ND'
    """
    try:
        res = float(s)
    except:
        res = np.nan
    return res

def good_row(z):
    """
    Retain days with no gaps (0 or NaN) in data
    """
    
    try:
        res = not any([(math.isnan(x) or (x == 0))
                       for x in z])
    except:
        res = False
    return res

if __name__ == '__main__':

    fname = os.path.join('..', 'data', 'frb_h15.csv')

    if not os.path.isfile(fname):
        url = get_frb_url(dtStart=date(2000,1,1),
                          dtEnd=date(2011,12,20))
        frb_site = urllib.urlopen(url)
        text = frb_site.read().strip()

        f = open(fname, 'w')
        f.write(text)
        f.close()

    # simpler labels

    columns_dic = {"RIFLDIY01_N.B":'Swap1Y',
               "RIFLDIY02_N.B":'Swap2Y',
               "RIFLDIY03_N.B":'Swap3Y',
               "RIFLDIY04_N.B":'Swap4Y',
               "RIFLDIY05_N.B":'Swap5Y',
               "RIFLDIY07_N.B":'Swap7Y',
               "RIFLDIY10_N.B":'Swap10Y',
               "RIFLDIY30_N.B":'Swap30Y',
               "RILSPDEPM01_N.B":'Libor1M',
               "RILSPDEPM03_N.B":'Libor3M',
               "RILSPDEPM06_N.B":'Libor6M'}

    # the data converter is applied to all columns
    # excluding the index column (0)

    dc_dict = {i: dataconverter for i
               in range(0,len(columns_dic.keys()))}

    df_libor = read_csv(fname, sep=',', header=True,
                    index_col=0, parse_dates=True,
                    converters=dc_dict,
                    skiprows=[0,1,2,3,4])

    df_libor = df_libor.rename(columns=columns_dic)

    good_rows = df_libor.apply(good_row, axis=1)
    
    df_libor_good = df_libor[good_rows]
    
    print df_libor_good

    df_libor_good.save(os.path.join('..', 'data', 'df_libor.pkl'))

