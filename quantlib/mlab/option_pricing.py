"""
 Copyright (C) 2012, Enthought Inc
 Copyright (C) 2012, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from scipy.interpolate import interp1d
from scipy.stats import norm

import numpy as np
import pandas
from pandas import DataFrame

import datetime
from datetime import date

from quantlib.models.equity.heston_model import (
    HestonModelHelper, HestonModel)

from quantlib.pricingengines.vanilla import AnalyticHestonEngine
from quantlib.processes.heston_process import HestonProcess
from quantlib.settings import Settings
from quantlib.time.api import Period, Date, Actual365Fixed, ActualActual, TARGET, Days
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.zero_curve import ZeroCurve

from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import (
            Put, Call, EuropeanExercise, VanillaOption)

from quantlib.util.QL_converter import dateToQLDate, dfToZeroCurve

def options_to_rates(optionDataFrame, tMin=1./12., nMin=6):
    
    """
    Extract implied risk-free rates and dividend yield from
    standard European option quote file.
  
    ignore data:
    - with time to maturity < tMin (in fraction of years)
    - with fewer than nMin quotes per maturity date

    """
    
    grouped = optionDataFrame.groupby('dtExpiry') 

    isFirst = True
    dt_exp = []
    vx_rate = []
    vx_div = []
    
    for spec, group in grouped:
        # print('processing group %s' % spec)

        # implied vol for this type/expiry group

        indx = group.index
        
        dtTrade = group['dtTrade'][indx[0]]
        dtExpiry = group['dtExpiry'][indx[0]]
        spot = group['Spot'][indx[0]]
        daysToExpiry = (dtExpiry-dtTrade).days
        timeToMaturity = daysToExpiry/365.0

        # exclude groups with too short time to maturity
        
        if timeToMaturity < tMin:
            continue
            
        # exclude groups with too few data points
        
        df_call = group[group['Type'] == 'C']
        df_put = group[group['Type'] == 'P']
        
        if (len(df_call) < nMin) | (len(df_put) < nMin):
            continue

        # calculate forward, implied interest rate and implied div. yield
            
        df_C = DataFrame((df_call['PBid']+df_call['PAsk'])/2,
                         columns=['PremiumC'])
        df_C.index = df_call['Strike']
        df_P = DataFrame((df_put['PBid']+df_put['PAsk'])/2,
                         columns=['PremiumP'])
        df_P.index = df_put['Strike']
        
        # use 'inner' join because some strikes are not quoted for C and P
        df_all = df_C.join(df_P, how='inner')
        df_all['Strike'] = df_all.index
        df_all['C-P'] = df_all['PremiumC'] - df_all['PremiumP']
    
	y = np.array(df_all['C-P'])
	x = np.array(df_all['Strike'])
	A = np.vstack([x, np.ones(len(x))]).T
	m, c = np.linalg.lstsq(A, y)[0]
	print m, c
        
        # intercept is last coef
        iRate = -np.log(-m)/timeToMaturity
        dRate = np.log(spot/c)/timeToMaturity

        vx_rate.append(iRate)
        vx_div.append(dRate)
        dt_exp.append(dtExpiry)
        
    df = DataFrame({'iRate': vx_rate, 'dRate': vx_div}, index=dt_exp)

    return df

def heston_pricer(dt_trade, df_option, params,
                  df_rates, spot):

    """
    price a list of European options with heston model
    """

    spot = SimpleQuote(spot)
        
    risk_free_ts = dfToZeroCurve(df_rates['iRate'], dt_trade)
    dividend_ts = dfToZeroCurve(df_rates['dRate'], dt_trade)

    process = HestonProcess(risk_free_ts, dividend_ts,
                            spot, params['v0'],
                            params['kappa'],
                            params['theta'],
                            params['sigma'],
                            params['rho'])

    model = HestonModel(process)
    engine = AnalyticHestonEngine(model, 64)

    Dt_settlement = dateToQLDate(dt_trade)
    
    settings = Settings()
    settings.evaluation_date = Dt_settlement

    calendar = TARGET()

    model_value = np.zeros(len(df_option))
    daycounter = ActualActual()
    
    for index, row in df_option.T.iteritems():

        dt_expiry = row['dtExpiry']

        strike = row['Strike']

        cp = Call if row['Type'] == 'C' else Put

        payoff = PlainVanillaPayoff(cp, strike)

        Dt_expiry = dateToQLDate(dt_expiry)
        exercise = EuropeanExercise(Dt_expiry)

        option = VanillaOption(payoff, exercise)

        option.set_pricing_engine(engine)
        
        model_value[index] = option.net_present_value
        
    df_final = DataFrame.filter(df_option,
                                items=['dtExpiry',
                                       'Strike',
                                       'Type', 'Spot'])
    df_final['HestonPrice'] = model_value
    df_final['dtTrade'] = dt_trade

    return df_final
