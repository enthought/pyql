"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from __future__ import division
from __future__ import print_function

# USD Deposit and Swap Rates
# ==========================
#
# This script shows how to process a curve of US deposit and swap rates.
# The data comes from the US Federal Reserve Board, and is published daily
# as a data set named 'Table H15'.
# Here, we extract a curve from the data set and construct a simple plot .

import os
import datetime
import pandas as pd
import pylab as pl

if __name__ == '__main__':

    # maturities in years
    maturities_dic = {'Swap1Y': 1,
                      'Swap2Y': 2,
                      'Swap3Y': 3,
                      'Swap4Y': 4,
                      'Swap5Y': 5,
                      'Swap7Y': 7,
                      'Swap10Y': 10,
                      'Swap30Y': 30,
                      'Libor1M': 1.0 / 12,
                      'Libor3M': 3.0 / 12,
                      'Libor6M': 6.0 / 12}

    dt_obs = datetime.datetime(2011, 12, 20)

    # extract a yield curve from data frame
    libor_rates = pd.load(os.path.join('..', 'data', 'df_libor.pkl'))
    df_libor = pd.DataFrame(libor_rates.xs(dt_obs), columns=['Rate'])

    # add maturity column
    df_libor['Maturity'] = [maturities_dic[k] for k in df_libor.index]

    # add maturity column
    df_libor['Maturity'] = [col_mat_dic[k] for k in df_libor.index]
    
    # ... and sort by increasing maturity
    df_libor = df_libor.sort_index(by='Maturity')

    print(df_libor)
    
    pl.plot(df_libor['Maturity'], df_libor['Rate'])
    pl.xlabel('Maturity (Yr)')
    pl.ylabel('Deposit/Libor Rate')
    pl.title('Libor Deposit and Swap Rates (%s) \n from Table H15 \
    at www.federalreserve.gov' % dt_obs.strftime('%d-%b-%Y'))
    pl.show()
