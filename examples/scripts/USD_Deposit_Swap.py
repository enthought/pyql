# -*- coding: utf-8 -*-
# <nbformat>3</nbformat>

# <markdowncell>

# USD Deposit and Swap Rates
# ==========================
# 
# This notebook shows how to process a curve of US deposit and swap rates. The data comes from the US Federal Reserve Board, and is published daily as a data set named 'Table H15'. 


# <codecell>

import os, datetime
import pandas as pd
import numpy as np
import pylab as pl

# <markdowncell>

# Extract and plot the data
# -------------------------

# <codecell>

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

    # ... and sort by increasing maturity
    df_libor = df_libor.sort_index(by='Maturity')

    pl.plot(df_libor['Maturity'], df_libor['Rate'])
    pl.xlabel('Maturity (Yr)')
    pl.ylabel('Deposit/Libor Rate')
    pl.title('Libor Deposit and Swap Rates (%s) \n from Table H15 at www.federalreserve.gov' % dt_obs.strftime('%d-%b-%Y'))
    show()
