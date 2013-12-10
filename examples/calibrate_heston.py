"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from __future__ import division
from __future__ import print_function

import numpy as np
import pandas
from pandas import DataFrame
import datetime

from quantlib.models.equity.heston_model import (
    HestonModelHelper, HestonModel, ImpliedVolError
)

from quantlib.models.equity.bates_model import (BatesModel, BatesDetJumpModel,
     BatesDoubleExpModel, BatesDoubleExpDetJumpModel)
from quantlib.processes.heston_process import HestonProcess
from quantlib.processes.bates_process import BatesProcess

from quantlib.pricingengines.api import (AnalyticHestonEngine, BatesEngine,
     BatesDetJumpEngine, BatesDoubleExpEngine, BatesDoubleExpDetJumpEngine)
from quantlib.math.optimization import LevenbergMarquardt, EndCriteria
from quantlib.settings import Settings
from quantlib.time.api import Period, Date, Actual365Fixed, TARGET, Days
from quantlib.quotes import SimpleQuote
from quantlib.util.converter import df_to_zero_curve, pydate_to_qldate


def heston_helpers(df_option, dtTrade=None, df_rates=None, ival=None):
    """
    Create array of heston options helpers
    """

    if dtTrade is None:
        dtTrade = df_option['dtTrade'][0]
    DtSettlement = pydate_to_qldate(dtTrade)

    settings = Settings()
    settings.evaluation_date = DtSettlement

    calendar = TARGET()

    if df_rates is None:
        df_tmp = DataFrame.filter(df_option, items=['dtExpiry', 'IR', 'IDIV'])
        grouped = df_tmp.groupby('dtExpiry')
        df_rates = grouped.agg(lambda x: x[0])

    # convert data frame (date/value) into zero curve
    # expect the index to be a date, and 1 column of values

    risk_free_ts = df_to_zero_curve(df_rates['R'], dtTrade)
    dividend_ts = df_to_zero_curve(df_rates['D'], dtTrade)

    # back out the spot from any forward
    iRate = df_option['R'][0]
    iDiv = df_option['D'][0]
    TTM = df_option['T'][0]
    Fwd = df_option['F'][0]
    spot = SimpleQuote(Fwd * np.exp(-(iRate - iDiv) * TTM))
    print('Spot: %f risk-free rate: %f div. yield: %f' % \
          (spot.value, iRate, iDiv))

    # loop through rows in option data frame, construct
    # helpers for bid/ask

    oneDay = datetime.timedelta(days=1)
    dtExpiry = [dtTrade + int(t * 365) * oneDay for t in df_option['T']]
    df_option['dtExpiry'] = dtExpiry

    options = []
    for index, row in df_option.T.iteritems():

        strike = row['K']
        if (strike / spot.value > 1.3) | (strike / spot.value < .7):
            continue

        days = int(365 * row['T'])
        maturity = Period(days, Days)

        options.append(
                HestonModelHelper(
                    maturity, calendar, spot.value,
                    strike, SimpleQuote(row['VB']),
                    risk_free_ts, dividend_ts,
                    ImpliedVolError))

        options.append(
                HestonModelHelper(
                    maturity, calendar, spot.value,
                    strike, SimpleQuote(row['VA']),
                    risk_free_ts, dividend_ts,
                    ImpliedVolError))

    return {'options': options, 'spot': spot}


def merge_df(df_option, options, model_name):
    df_output = DataFrame.filter(df_option,
                items=['dtTrade', 'dtExpiry',
                       'Type', 'K', 'Mid',
                       'QuickDelta', 'VB', 'VA',
                       'R', 'D', 'ATMVol', 'F', 'T'])

    model_value = np.zeros(len(df_option))
    model_iv = np.zeros(len(df_option))
    for i, j in zip(range(len(df_option)), range(0, len(options), 2)):
        model_value[i] = options[j].model_value()
        model_iv[i] = options[j].impliedVolatility(model_value[i],
            accuracy=1.e-5, maxEvaluations=5000,
            minVol=.01, maxVol=10.0)

    df_output[model_name + '-Value'] = model_value
    df_output[model_name + '-IV'] = model_iv

    return df_output


def bates_calibration(df_option, dtTrade=None, df_rates=None, ival=None):

    # array of option helpers
    hh = heston_helpers(df_option, dtTrade, df_rates, ival)
    options = hh['options']
    spot = hh['spot']

    risk_free_ts = df_to_zero_curve(df_rates['R'], dtTrade)
    dividend_ts = df_to_zero_curve(df_rates['D'], dtTrade)

    v0 = .02

    if ival is None:
        ival = {'v0': v0, 'kappa': 3.7, 'theta': v0,
        'sigma': 1.0, 'rho': -.6, 'lambda': .1,
        'nu': -.5, 'delta': 0.3}

    process = BatesProcess(
        risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
         ival['theta'], ival['sigma'], ival['rho'],
         ival['lambda'], ival['nu'], ival['delta'])

    model = BatesModel(process)
    engine = BatesEngine(model, 64)

    for option in options:
        option.set_pricing_engine(engine)

    om = LevenbergMarquardt()
    model.calibrate(
        options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
    )

    print('model calibration results:')
    print('v0: %f kappa: %f theta: %f sigma: %f\nrho: %f lambda: \
    %f nu: %f delta: %f' %
          (model.v0, model.kappa, model.theta, model.sigma,
           model.rho, model.Lambda, model.nu, model.delta))

    calib_error = (1.0 / len(options)) * sum(
        [pow(o.calibration_error(), 2) for o in options])

    print('SSE: %f' % calib_error)

    return merge_df(df_option, options, 'Bates')


def heston_calibration(df_option, dtTrade=None, df_rates=None, ival=None):
    """
    calibrate heston model
    """

    # array of option helpers
    print(df_option, df_rates, ival)
    hh = heston_helpers(df_option, dtTrade, df_rates, ival)
    options = hh['options']
    spot = hh['spot']

    risk_free_ts = df_to_zero_curve(df_rates['R'], dtTrade)
    dividend_ts = df_to_zero_curve(df_rates['D'], dtTrade)

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

    calib_error = (1.0 / len(options)) * sum(
        [pow(o.calibration_error() * 100.0, 2) for o in options])

    print('SSE: %f' % calib_error)

    return merge_df(df_option, options, 'Heston')


def batesdetjump_calibration(df_option, dtTrade=None,
                             df_rates=None, ival=None):

    # array of option helpers
    hh = heston_helpers(df_option, dtTrade, df_rates, ival)
    options = hh['options']
    spot = hh['spot']

    risk_free_ts = df_to_zero_curve(df_rates['R'], dtTrade)
    dividend_ts = df_to_zero_curve(df_rates['D'], dtTrade)

    v0 = .02

    if ival is None:
        ival = {'v0': v0, 'kappa': 3.7, 'theta': v0,
        'sigma': 1.0, 'rho': -.6, 'lambda': .1,
        'nu': -.5, 'delta': 0.3}

    process = BatesProcess(
        risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
         ival['theta'], ival['sigma'], ival['rho'],
         ival['lambda'], ival['nu'], ival['delta'])

    model = BatesDetJumpModel(process)
    engine = BatesDetJumpEngine(model, 64)

    for option in options:
        option.set_pricing_engine(engine)

    om = LevenbergMarquardt()
    model.calibrate(
        options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
    )

    print('BatesDetJumpModel calibration:')
    print('v0: %f kappa: %f theta: %f sigma: %f\nrho: %f lambda: %f nu: %f \
    delta: %f\nkappaLambda: %f thetaLambda: %f' %
          (model.v0, model.kappa, model.theta, model.sigma,
           model.rho, model.Lambda, model.nu, model.delta,
           model.kappaLambda, model.thetaLambda))

    calib_error = (1.0 / len(options)) * sum(
        [pow(o.calibration_error(), 2) for o in options])

    print('SSE: %f' % calib_error)

    return merge_df(df_option, options, 'BatesDetJump')


def batesdoubleexp_calibration(df_option, dtTrade=None,
                               df_rates=None, ival=None):

    # array of option helpers
    hh = heston_helpers(df_option, dtTrade, df_rates, ival)
    options = hh['options']
    spot = hh['spot']

    risk_free_ts = df_to_zero_curve(df_rates['R'], dtTrade)
    dividend_ts = df_to_zero_curve(df_rates['D'], dtTrade)

    v0 = .02

    if ival is None:
        ival = {'v0': v0, 'kappa': 3.7, 'theta': v0,
        'sigma': 1.0, 'rho': -.6, 'lambda': .1,
        'nu': -.5, 'delta': 0.3}

    process = HestonProcess(
        risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
         ival['theta'], ival['sigma'], ival['rho'])

    model = BatesDoubleExpModel(process)
    engine = BatesDoubleExpEngine(model, 64)

    for option in options:
        option.set_pricing_engine(engine)

    om = LevenbergMarquardt()
    model.calibrate(
        options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
    )

    print('BatesDoubleExpModel calibration:')
    print('v0: %f kappa: %f theta: %f sigma: %f\nrho: %f lambda: %f \
    nuUp: %f nuDown: %f\np: %f' %
          (model.v0, model.kappa, model.theta, model.sigma,
           model.rho, model.Lambda, model.nuUp, model.nuDown,
           model.p))

    calib_error = (1.0 / len(options)) * sum(
        [pow(o.calibration_error(), 2) for o in options])

    print('SSE: %f' % calib_error)

    return merge_df(df_option, options, 'BatesDoubleExp')


def batesdoubleexpdetjump_calibration(df_option, dtTrade=None,
                                      df_rates=None, ival=None):

    # array of option helpers
    hh = heston_helpers(df_option, dtTrade, df_rates, ival)
    options = hh['options']
    spot = hh['spot']

    risk_free_ts = df_to_zero_curve(df_rates['R'], dtTrade)
    dividend_ts = df_to_zero_curve(df_rates['D'], dtTrade)

    v0 = .02

    if ival is None:

        ival = {'v0': v0, 'kappa': 3.7, 'theta': v0,
        'sigma': .1, 'rho': -.6, 'lambda': .1,
        'nu': -.5, 'delta': 0.3}

    process = HestonProcess(
        risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
         ival['theta'], ival['sigma'], ival['rho'])

    model = BatesDoubleExpDetJumpModel(process, 1.0)
    engine = BatesDoubleExpDetJumpEngine(model, 64)

    for option in options:
        option.set_pricing_engine(engine)

    om = LevenbergMarquardt()
    model.calibrate(
        options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
    )

    print('BatesDoubleExpDetJumpModel calibration:')
    print('v0: %f kappa: %f theta: %f sigma: %f\nrho: %f lambda: %f \
    nuUp: %f nuDown: %f\np: %f\nkappaLambda: %f thetaLambda: %f' %
          (model.v0, model.kappa, model.theta, model.sigma,
           model.rho, model.Lambda, model.nuUp, model.nuDown,
           model.p, model.kappaLambda, model.thetaLambda))

    calib_error = (1.0 / len(options)) * sum(
        [pow(o.calibration_error(), 2) for o in options])

    print('SSE: %f' % calib_error)

    return merge_df(df_option, options, 'BatesDoubleExpDetJump')

df_rates = pandas.load('data/df_rates.pkl')

# data set with no smoothing
df_option = pandas.load('data/df_SPX_24jan2011.pkl')
dtTrade = df_option['dtTrade'][0]

if True:
    print('heston calibration...')
    df_output = heston_calibration(df_option, dtTrade,
                               df_rates)
    df_output.save('data/df_calibration_output_heston.pkl')

if False:
    print('bates calibration...')
    df_output = bates_calibration(df_option, dtTrade,
                               df_rates)
    df_output.save('data/df_calibration_output_bates.pkl')

if False:
    print('batesdetjump calibration...')
    df_output = batesdetjump_calibration(df_option, dtTrade,
                               df_rates)
    df_output.save('data/df_calibration_output_batesdetjump.pkl')

if False:
    print('bates double exp calibration...')
    df_output = batesdoubleexp_calibration(df_option, dtTrade,
                               df_rates)
    df_output.save('data/df_calibration_output_batesdoubleexp.pkl')

if False:
    print('bates double exp det jump calibration...')
    df_output = batesdoubleexpdetjump_calibration(df_option, dtTrade,
                               df_rates)
    df_output.save('data/df_calibration_output_batesdoubleexpdetjump.pkl')
