# -*- coding: utf-8 -*-
# <nbformat>3</nbformat>

# <markdowncell>

# Risk Factors in USD Libor Market
# ================================
# 
# In this notebook, we perform a classical analysis in risk management. Using 11 years of USD libor data (deposit and swap rates), we:
# 
# - Compute a time series of zero-coupon curves, bootstrapped from the deposit and swap rates, using the QuantLib library
# - Sample these zero-coupon curves at constant maturities
# - Perform a Principal Components Analysis on the change in zero-coupon rates, using the numpy library
# 
# The first 3 principal components account for over 95% of the total variance, and can be interpreted as follows:
# 
# * The first factor represents an approximate parallel shift
# * The second factor represents a twist
# * The third factor represents a change in convexity

# <markdowncell>

# Utility functions
# -----------------

# <codecell>

from quantlib.settings import Settings
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper, SwapRateHelper
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory
from quantlib.time.api import (Date, TARGET, Period, Months, Years, Days,
                               ModifiedFollowing, Unadjusted, Actual360,
                               Thirty360, ActualActual, ISDA, today,
                                JointCalendar, UnitedStates, UnitedKingdom)

from quantlib.currency import USDCurrency
from quantlib.quotes import SimpleQuote

from quantlib.indexes.libor import Libor
from quantlib.time.date import Semiannual, Annual

import datetime, os

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.mlab as ml

import pandas

def QLDateTodate(dt):
    """
    Converts a QL Date to a datetime
    """
    
    return datetime.datetime(dt.year, dt.month, dt.day)
    
def dateToDate(dt):
    """
    Converts a python date to a QL Date
    """
    return Date(dt.day, dt.month, dt.year)

# <markdowncell>

# Bootstrapping a Zero-Coupon Yield Curve
# ---------------------------------------
# 
# The zero-coupon yield curve is bootstrapped from deposit and swap rates. The function takes a pandas DataFrame and a calculation date as input, extracts from the data frame the corresponding row, and computes the zero-coupon curve.

# <codecell>

def get_term_structure(df_libor, dtObs):
    
    settings = Settings()

    # libor as fixed in London, but cash-flows are determined according to
    # US calendar, hence the need to combine both holidays lists
    calendar = JointCalendar(UnitedStates(), UnitedKingdom())
    
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
        helper = DepositRateHelper(float(rate/100), tenor,
                 settlement_days,
                 calendar, ModifiedFollowing,
                 end_of_month,
                 Actual360())

        rate_helpers.append(helper)

    endOfMonth = True

    liborIndex = Libor('USD Libor', Period(6, Months),
                       settlement_days,
                       USDCurrency(), calendar,
                       Actual360())

    spread = SimpleQuote(0)
    fwdStart = Period(0, Days)

    for m, period, label in swapData:
        rate = df_libor.get_value(dtObs, label)
        helper = SwapRateHelper.from_tenor(rate/100.,
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

# <markdowncell>

# Sampling the Zero-Coupon Curve at Constant Maturities
# -----------------------------------------------------
# 
# In order to perform a statistical analysis on the daily rate changes, one needs to construct a data set of zero-coupon rates of constant maturity. This is done by the following function, which takes as input a QuantLib term structure and its settlement date. The function returns the tuple (vector of maturity dates, vector of zero-coupon rates).

# <codecell>

def zero_curve(ts, days, dtObs):
    calendar = TARGET()
    dtMat = [calendar.advance(dateToDate(dtObs), d, Days) for d in days]
    df = np.array([ts.discount(dt) for dt in dtMat])
    dtMat = [QLDateTodate(dt) for dt in dtMat]
    dtToday = QLDateTodate(dtObs)
    dt = np.array([(d-dtToday).days/365.0 for d in dtMat])
    zc = -np.log(df) / dt
    return (dtMat, zc)

# <markdowncell>

# Time Series of Constant-Maturity Zero-Coupon Curves
# ---------------------------------------------------

# <codecell>


df_libor = pandas.load(os.path.join('..','data','df_libor.pkl'))
print df_libor
dtObs = df_libor.index

dtI = dtObs[range(0, len(dtObs)-1, 60)]
days = [10, 30, 90, 182, 365, 365*2, 365*3, 365*5, 365*10, 365*15]

# maturity in columns, observation days in rows

zc_rate = np.empty((len(dtI), len(days)), dtype='float64')
dt_maturity = np.empty_like(zc_rate, dtype='object')

for i, dt in enumerate(dtI):
    ts = get_term_structure(df_libor, dt)
    (dt_maturity[i,], zc_rate[i,]) = zero_curve(ts, days, dt)
        

# <markdowncell>

# Principal Components Analysis and Display
# -----------------------------------------
# 
# The first three principal components identify the three major risk factors, and account for 95% of the total variance:
# 
# * The first factor represents an approximate parallel shift
# * The second factor represents a twist
# * The third factor represents a change in convexity

# <codecell>

# PCA on rate change
zc_pca = ml.PCA(np.diff(zc_rate, axis=0))

fig = plt.figure()
fig.set_size_inches(10,6)

ax = fig.add_subplot(121)

# compute x-axis limits
dtCalc = dtObs[0]
ts = get_term_structure(df_libor, dtCalc)
(dtMat, zc) = zero_curve(ts, days, dtCalc)
dtMin = dtMat[0]
    
dtCalc = dtObs[-1]
ts = get_term_structure(df_libor, dtCalc)
(dtMat, zc) = zero_curve(ts, days, dtCalc)
dtMax = dtMat[-1]
    
ax.set_xlim(dtMin, dtMax)
ax.set_ylim(0.0, 0.1)
    
# plot a few curves
for i in range(0, len(dtI),3):
    ax.plot(dt_maturity[i,], zc_rate[i,])
plt.title('Zero-Coupon USD Libor: 2000 to 2010')

ax2 = fig.add_subplot(122)
ttm = np.array(days)/365.0
ax2.plot(ttm, zc_pca.Wt[0,], 'k--', ttm, zc_pca.Wt[1,], 'k:', ttm, zc_pca.Wt[3,], 'k')
leg = ax2.legend(('PC 1', 'PC 2', 'PC 3'))
plt.title('First 3 Principal Components of USD Libor')
plt.show()

