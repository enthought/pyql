"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

# Libor Zero-Coupon Curve and Principal Components Analysis
# =========================================================

# This script demonstrates how to build a Libor zero-coupon curve
# from deposit and swap rates. It also performs a statistical
# a statistical analysis on curve shifts, and shows that
# the 3 principal components accounts for most of the
# curve variability and can be interpreted as follows:
#
# * The first factor represents an approximate parallel shift
# * The second factor represents a twist
# * The third factor represents a change in convexity

import os

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.mlab as ml

import pandas as pd
from quantlib.mlab.rates import zero_rate, make_term_structure


if __name__ == '__main__':

    df_libor = pd.load(os.path.join('..', 'data', 'df_libor.pkl'))

    dtObs = df_libor.index

    dtI = dtObs[range(0, len(dtObs) - 1, 60)]
    days = [10, 30, 90, 182, 365, 365 * 2, 365 * 3,
            365 * 5, 365 * 10, 365 * 15]

    # maturity in columns, observation days in rows
    zc_rate = np.empty((len(dtI), len(days)), dtype='float64')
    dt_maturity = np.empty_like(zc_rate, dtype='object')

    # one observation date at a time, construct a term structure from
    # deposit and swap rates, then compute zero-coupon rates at
    # selected maturities
    for i, obs_date in enumerate(dtI):
        print(obs_date)
        rates = df_libor.xs(obs_date) / 100
        ts = make_term_structure(rates, obs_date)
        (dt_maturity[i, ], zc_rate[i, ]) = zero_rate(ts, days, obs_date)

    # PCA on rate change
    zc_pca = ml.PCA(np.diff(zc_rate, axis=0))

    fig = plt.figure()
    fig.set_size_inches(10, 6)

    ax = fig.add_subplot(121)

    dtMin = dt_maturity[0, 0]
    dtMax = dt_maturity[-1, -1]
    ax.set_xlim(dtMin, dtMax)
    ax.set_ylim(0.0, 0.1)

    # plot a few curves
    for i in range(0, len(dtI), 3):
        ax.plot(dt_maturity[i, ], zc_rate[i, ])
    plt.title('Zero-Coupon USD Libor: 2000 to 2010')

    ax2 = fig.add_subplot(122)
    ttm = np.array(days) / 365.0
    ax2.plot(ttm, zc_pca.Wt[0, ], 'k--', ttm, zc_pca.Wt[1, ], 'k:', ttm,
             zc_pca.Wt[2, ], 'k')
    leg = ax2.legend(('PC 1', 'PC 2', 'PC 3'))
    plt.title('First 3 Principal Components of USD Libor')
    plt.show()
