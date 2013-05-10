# -*- coding: utf-8 -*-
# <nbformat>3</nbformat>

# <markdowncell>

# Calibration of Heston's Model on SPX data
# =======================================
# 
# This notebook demonstrates the calibration of Heston's model on SPX data, using the QuantLib hestonmodel class. 
# The code is adapted from the test suite written by Klaus Spandersen.
# 
# The calibration function takes as input a `pandas.DataFrame` constructed in notebook OptionQuotes.
# 
# QuantLib dependencies
# ---------------------

# <codecell>

import numpy as np
import pandas
from pandas import DataFrame
import datetime

from quantlib.models.equity.heston_model import (
    HestonModelHelper, HestonModel, ImpliedVolError)

from quantlib.processes.heston_process import HestonProcess
from quantlib.pricingengines.api import AnalyticHestonEngine
from quantlib.math.optimization import LevenbergMarquardt, EndCriteria
from quantlib.settings import Settings
from quantlib.time.api import Period, Date, Actual365Fixed, TARGET, Days
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.zero_curve import ZeroCurve

import matplotlib.pyplot as plt

# <markdowncell>

# Utility functions
# -----------------
# 
# The calibration process uses some utility functions, defined below.

# <codecell>

def dateToQLDate(dt):
    """
    Converts a datetime object into a QL Date
    """
    
    return Date(dt.day, dt.month, dt.year)

def dfToZeroCurve(df_rates, dtSettlement, daycounter=Actual365Fixed()):
    """
    Convert a panda data frame into a QL zero curve
    """
    
    dates = [dateToQLDate(dt) for dt in df_rates.index]
    dates.insert(0, dateToQLDate(dtSettlement))
    dates.append(dates[-1]+365*2)
    vx = list(df_rates.values)
    vx.insert(0, vx[0])
    vx.append(vx[-1])
    return ZeroCurve(dates, vx, daycounter)

# <markdowncell>

# Market data is converted into a set of helper objects, one per data point. For each strike
# and maturity, we construct a helper for the bid and ask prices.

# <codecell>

def heston_helpers(spot, df_option, dtTrade, df_rates):
    """
    Create array of heston options helpers
    """

    DtSettlement = dateToQLDate(dtTrade)
    
    settings = Settings()
    settings.evaluation_date = DtSettlement

    calendar = TARGET()

    # convert data frame (date/value) into zero curve
    # expect the index to be a date, and 1 column of values

    risk_free_ts = dfToZeroCurve(df_rates['iRate'], dtTrade)
    dividend_ts = dfToZeroCurve(df_rates['iDiv'], dtTrade)

    # loop through rows in option data frame, construct
    # helpers for bid/ask

    oneDay = datetime.timedelta(days=1)
    dtExpiry = [dtTrade + int(t*365)*oneDay for t in df_option['TTM']]
    df_option['dtExpiry'] = dtExpiry

    options = []
    for index, row in df_option.T.iteritems():

        strike = row['Strike']
        if (strike/spot.value > 1.3) | (strike/spot.value < .7):
            continue

        days = int(365*row['TTM'])
        maturity = Period(days, Days)

        options.append(
                HestonModelHelper(
                    maturity, calendar, spot.value,
                    strike, SimpleQuote(row['IVBid']),
                    risk_free_ts, dividend_ts,
                    ImpliedVolError))
        
        options.append(
                HestonModelHelper(
                    maturity, calendar, spot.value,
                    strike, SimpleQuote(row['IVAsk']),
                    risk_free_ts, dividend_ts,
                    ImpliedVolError))

    return {'options':options, 'spot': spot}

# <markdowncell>

# The function merge_df merges the result of the calibration (fitted option price and fitted implied volatility)
# with the input data set. This will facilitate the plotting of actual vs. fitted volatility.

# <codecell>

def merge_df(df_option, options, model_name):
    df_output = DataFrame.filter(df_option,
                items=['dtTrade', 'dtExpiry',
                       'Type', 'Strike', 'Mid',
                       'QuickDelta', 'IVBid', 'IVAsk',
                       'iRate', 'iDiv', 'ATMVol', 'Fwd', 'TTM'])

    model_value = np.zeros(len(df_option))
    model_iv = np.zeros(len(df_option))
    for i, j in zip(range(len(df_option)), range(0, len(options),2)):
        model_value[i] = options[j].model_value()
        model_iv[i] = options[j].impliedVolatility(model_value[i],
            accuracy=1.e-5, maxEvaluations=5000,
            minVol=.01, maxVol=10.0)

    df_output[model_name + '-Value'] = model_value
    df_output[model_name + '-IV'] = model_iv
    
    return df_output

# <markdowncell>

# The calibration process
# -----------------------
# 
# The calibration process is performed by the following function.

# <codecell>

def heston_calibration(df_option, ival=None):
    """
    calibrate heston model
    """

    # extract rates and div yields from the data set    
    df_tmp = DataFrame.filter(df_option, items=['dtExpiry', 'iRate', 'iDiv'])
    grouped = df_tmp.groupby('dtExpiry')
    df_rates = grouped.agg(lambda x: x[0])
    
    dtTrade = df_option['dtTrade'][0]
    # back out the spot from any forward
    iRate = df_option['iRate'][0]
    iDiv = df_option['iDiv'][0]
    TTM = df_option['TTM'][0]
    Fwd = df_option['Fwd'][0]
    spot = SimpleQuote(Fwd*np.exp(-(iRate-iDiv)*TTM))
    print('Spot: %f risk-free rate: %f div. yield: %f' % (spot.value, iRate, iDiv))
    
    # build array of option helpers
    hh = heston_helpers(spot, df_option, dtTrade, df_rates)
    options = hh['options']
    spot = hh['spot']

    risk_free_ts = dfToZeroCurve(df_rates['iRate'], dtTrade)
    dividend_ts = dfToZeroCurve(df_rates['iDiv'], dtTrade)

    # initial values for parameters
    if ival is None:
        ival = {'v0': 0.1, 'kappa': 1.0, 'theta': 0.1,
        'sigma': 0.5, 'rho': -.5}

    process = HestonProcess(
        risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
         ival['theta'], ival['sigma'], ival['rho'])

    model = HestonModel(process)
    engine = AnalyticHestonEngine(model, 64)

    for option in options:
        option.set_pricing_engine(engine)

    om = LevenbergMarquardt(1e-8, 1e-8, 1e-8)
    model.calibrate(
        options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
    )

    print('model calibration results:')
    print('v0: %f kappa: %f theta: %f sigma: %f rho: %f' %
          (model.v0, model.kappa, model.theta, model.sigma,
           model.rho))

    calib_error = (1.0/len(options)) * sum(
        [pow(o.calibration_error()*100.0,2) for o in options])

    print('SSE: %f' % calib_error)

    # merge the fitted volatility and the input data set
    return merge_df(df_option, options, 'Heston')

# <markdowncell>

# Calibration
# -----------
# 
# Finally, the calibration is performed by first loading the option data and calling the calibration routine.

# <codecell>

df_options = pandas.load('../data/df_options_SPX_24jan2011.pkl')
df_heston_cal = heston_calibration(df_options)

# <markdowncell>

# Plot Actual vs. Fitted Implied Volatility
# -----------------------------------------
# 
# We display 4 graphs in one plot, and show the bid/ask market volatility with the fitted volatility
# for selected maturities.

# <codecell>

def calibration_subplot(ax, group, i, model_name):
    group = group.sort_index(by='Strike')
    dtExpiry = group.get_value(group.index[0], 'dtExpiry')
    K = group['Strike']
    VB = group['IVBid']
    VA = group['IVAsk']
    VM = group[model_name + '-IV']

    ax.plot(K, VA, 'b.', K,VB,'b.', K,VM,'r-')
    if i==3:
        ax.set_xlabel('Strike')
    if i==0:
        ax.set_ylabel('Implied Vol')
    ax.text(.6,.8,'%s' % dtExpiry, transform=ax.transAxes)
    
def calibration_plot(title, df_calibration, model_name):
    df_calibration = DataFrame.filter(df_calibration,
                    items=['dtExpiry', 
                           'Strike', 'IVBid', 'IVAsk',
                           'TTM', model_name+'-IV'])

    # group by maturity
    grouped = df_calibration.groupby('dtExpiry')

    all_groups = [(dt, g) for dt, g in grouped]
    
    xy = [(0,0), (0,1), (1,0), (1,1)]

    for k in range(0, len(all_groups),4):
        if (k+4) >= len(all_groups):
            break
        plt.figure()
        fig, axs = plt.subplots(2, 2, sharex=True, sharey=True)

        for i in range(4):
            x,y = xy[i]
            calibration_subplot(axs[x,y], all_groups[i+k][1],i, model_name)
        plt.show()

# <codecell>

dtTrade = df_options['dtTrade'][0]
title = 'Heston Model (%s)' % dtTrade
calibration_plot(title, df_heston_cal, 'Heston')

