"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

# This script demonstrates the calculation of a US Libor zero-coupon
# curve, using Euro-deposits and swap rates provided by the FRB

# WORK IN PROGRESS

import scikits.timeseries as ts
import numpy as np
import math
import numpy.ma as ma

# data from the federal reserve system
# http://www.federalreserve.gov/datadownload/Choose.aspx?rel=H15

fname = "./data/FRB_H15.csv"

dateconverter = lambda d: ts.Date(freq='D', string=d)

# data file has 
# - numeric cells
# - empty cells
# cells with 'NC' or 'ND'

def dataconverter(s):
    if s in ('NC', 'ND'):
        return np.nan
    else:
        return float(s)

column_names=('SWAP1Y', 'SWAP2Y', 'SWAP3Y', 'SWAP4Y',
        'SWAP5Y', 'SWAP7Y', 'SWAP10Y', 'SWAP30Y',
        'LIBOR1M', 'LIBOR3M', 'LIBOR6M')
 
# all numeric data interpreted in the same way
dc_dict = {i: dataconverter for i in range(1,len(column_names)+1)}
          
z = ts.tsfromtxt(fname, dtype=None, delimiter=',',
                skip_header=6, datecols=0,
                dateconverter=dateconverter,
                converters = dc_dict,
                names=column_names)
                        
# keep dates with complete record
# TODO: there must be a better way to do this

def good_row(z):
    try:
        res = not any([math.isnan(x) for x in z])
    except:
        res = False
    return res

status_index = [good_row(z[k,]) for k in range(len(z))]
good_index = np.where(status_index)[0] 

z_good = z[good_index]

# TODO: zero coupon curve









