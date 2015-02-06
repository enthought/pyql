"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from __future__ import division
from __future__ import print_function

# This script shows how to build libor zero-coupon
# curves from deposits and swap rates, and plot
# a series of such curves

from quantlib.settings import Settings
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper, SwapRateHelper
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory
from quantlib.time.api import Date, TARGET, Period, Months, Years, Days
from quantlib.time.api import (ModifiedFollowing, Unadjusted, Actual360,
                               Thirty360, ActualActual)

from quantlib.time.api import September, ISDA, today
from quantlib.currency import USDCurrency
from quantlib.quotes import SimpleQuote

from quantlib.indexes.libor import Libor
from quantlib.time.date import Semiannual, Annual

import datetime

import numpy as np
import matplotlib.pyplot as plt
import pandas

def QLDateTodate(dt):
    """
    Converts a QL Date to a datetime
    """
    
    return datetime.datetime(dt.year, dt.month, dt.day)
    
def dateToDate(dt):
    return Date(dt.day, dt.month, dt.year)

def get_term_structure(df_libor, dtObs):
    
    settings = Settings()

    # Market information
    calendar = TARGET()

    # must be a business day
    eval_date = calendar.adjust(dateToDate(dtObs))
    settings.evaluation_date = eval_date

    settlement_days = 2
    settlement_date = calendar.advance(eval_date, settlement_days, Days)
    # must be a business day
    settlement_date = calendar.adjust(settlement_date);

    depositData =[[1, Months, 'Libor1M'],
                  [3, Months, 'Libor3M'],
                  [6, Months, 'Libor6M']]

    swapData = [[ 1, Years, 'Swap1Y'],
                [ 2, Years, 'Swap2Y'],
                [ 3, Years, 'Swap3Y'],
                [ 4, Years, 'Swap4Y'],
                [ 5, Years, 'Swap5Y'],
                [ 7, Years, 'Swap7Y'],
                [ 10, Years,'Swap10Y'],
                [ 30, Years,'Swap30Y']]

    rate_helpers = []

    end_of_month = True

    for m, period, label in depositData:
        tenor = Period(m, Months)
        rate = df_libor.get_value(dtObs, label)
        helper = DepositRateHelper(float(rate/100.0), tenor,
                 settlement_days,
                 calendar, ModifiedFollowing,
                 end_of_month,
                 Actual360())

        rate_helpers.append(helper)

    endOfMonth = True

    liborIndex = Libor('USD Libor', Period(6, Months),
                       settlement_days,
                       USDCurrency(), calendar,
                       ModifiedFollowing,
                       endOfMonth, Actual360())

    spread = SimpleQuote(0)
    fwdStart = Period(0, Days)

    for m, period, label in swapData:
        rate = df_libor.get_value(dtObs, label)
        helper = SwapRateHelper(SimpleQuote(rate/100.0),
                 Period(m, Years), 
            calendar, Annual,
            Unadjusted, Thirty360(),
            liborIndex, spread, fwdStart)

        rate_helpers.append(helper)

    ts_day_counter = ActualActual(ISDA)
    tolerance = 1.0e-15

    ts = term_structure_factory('discount', 'loglinear',
         settlement_date, rate_helpers,
         ts_day_counter, tolerance)

    return ts

def zero_curve(ts, dtObs):
    calendar = TARGET()
    days = range(10, 365*20, 30)
    dtMat = [calendar.advance(dateToDate(dtObs), d, Days) for d in days]
    df = np.array([ts.discount(dt) for dt in dtMat])
    dtMat = [QLDateTodate(dt) for dt in dtMat]
    dtToday = QLDateTodate(dtObs)
    dt = np.array([(d-dtToday).days/365.0 for d in dtMat])
    zc = -np.log(df) / dt
    return (dtMat, zc)

if __name__ == '__main__':
    
    df_libor = pandas.load('data/df_libor.pkl')
    dtObs = df_libor.index
    
    fig = plt.figure()
    ax = fig.add_subplot(111)

    # compute x-axis limits
    ts = get_term_structure(df_libor, dtObs[0])
    (dtMat, zc) = zero_curve(ts, dtObs[0])
    dtMin = dtMat[0]
    ts = get_term_structure(df_libor, dtObs[-1])
    (dtMat, zc) = zero_curve(ts, dtObs[-1])
    dtMax = dtMat[-1]
    
    print('dtMin %s dtMax %s' % (dtMin, dtMax))
    
    ax.set_xlim(dtMin, dtMax)
    ax.set_ylim(0.0, 0.1)
    
    dtI = dtObs[range(0, len(dtObs)-1, 100)]
    for dt in dtI:
        ts = get_term_structure(df_libor, dt)
        (dtMat, zc) = zero_curve(ts, dt)
        ax.plot(dtMat, zc)
    
    plt.title('Zero-coupon USD Libor from %s to %s' %
         (dtI[0].strftime('%m/%d/%Y'),
          dtI[-1].strftime('%m/%d/%Y')))
    
    plt.show()
    
    
