"""
 Copyright (C) 2012, Enthought Inc
 Copyright (C) 2012, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import numpy as np
import quantlib.reference.names as nm

from quantlib.instruments.option import VanillaOption, OptionType
from quantlib.instruments.exercise import EuropeanExercise
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.models.equity.heston_model import HestonModel
from quantlib.processes.heston_process import HestonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.util.converter import pydate_to_qldate, df_to_zero_curve

from quantlib.instruments.api import EuropeanOption
from quantlib.pricingengines.api import (AnalyticEuropeanEngine,
                                         AnalyticHestonEngine)
from quantlib.processes.api import BlackScholesMertonProcess
from quantlib.termstructures.yields.api import FlatForward, HandleYieldTermStructure
from quantlib.termstructures.volatility.api import BlackConstantVol
from quantlib.time.api import today, NullCalendar, ActualActual

from quantlib.time.date import (Period, Days)
from quantlib.mlab.util import common_shape, array_call


def heston_pricer(trade_date, options, params, rates, spot):
    """
    Price a list of European options with heston model.

    """

    spot = SimpleQuote(spot)

    risk_free_ts = HandleYieldTermStructure(df_to_zero_curve(rates[nm.INTEREST_RATE], trade_date))
    dividend_ts = HandleYieldTermStructure(df_to_zero_curve(rates[nm.DIVIDEND_YIELD], trade_date))

    process = HestonProcess(risk_free_ts, dividend_ts, spot, **params)

    model = HestonModel(process)
    engine = AnalyticHestonEngine(model)

    settlement_date = pydate_to_qldate(trade_date)

    settings = Settings()
    settings.evaluation_date = settlement_date

    modeled_values = np.zeros(len(options))
    for index, row in options.iterrows():

        expiry_date = row[nm.EXPIRY_DATE]
        strike = row[nm.STRIKE]

        option_type = OptionType.Call if row[nm.OPTION_TYPE] == nm.CALL_OPTION else OptionType.Put

        payoff = PlainVanillaPayoff(option_type, strike)

        expiry_qldate = pydate_to_qldate(expiry_date)
        exercise = EuropeanExercise(expiry_qldate)

        option = VanillaOption(payoff, exercise)
        option.set_pricing_engine(engine)

        modeled_values[index] = option.net_present_value

    prices = options.filter(items=[nm.EXPIRY_DATE, nm.STRIKE,
                                   nm.OPTION_TYPE, nm.SPOT])
    prices[nm.PRICE] = modeled_values
    prices[nm.TRADE_DATE] = trade_date

    return prices


def blsprice(spot, strike, risk_free_rate, time, volatility,
             option_type=OptionType.Call, dividend=0.0, calc='price'):

    """
    Matlab's blsprice + greeks (delta, gamma, theta, rho, vega, lambda)
    """
    args = locals()
    the_shape, shape = common_shape(args)

    all_scalars = np.all([shape[key][0] == 'scalar' for key in shape])

    if all_scalars:
        res = _blsprice(**args)
    else:
        res = array_call(_blsprice, shape, args)
        res = np.reshape(res, the_shape)
    return res


def _blsprice(spot, strike, risk_free_rate, time, volatility,
              option_type, dividend, calc):
    """
    Black-Scholes option pricing model + greeks.
    """
    _spot = SimpleQuote(spot)

    daycounter = ActualActual(ActualActual.ISMA)
    risk_free_ts = HandleYieldTermStructure(FlatForward(today(), risk_free_rate, daycounter))
    dividend_ts = HandleYieldTermStructure(FlatForward(today(), dividend, daycounter))
    volatility_ts = BlackConstantVol(today(), NullCalendar(),
                                     volatility, daycounter)

    process = BlackScholesMertonProcess(_spot, dividend_ts,
                                        risk_free_ts, volatility_ts)

    exercise_date = today() + Period(time * 365, Days)
    exercise = EuropeanExercise(exercise_date)

    payoff = PlainVanillaPayoff(option_type, strike)

    option = EuropeanOption(payoff, exercise)
    engine = AnalyticEuropeanEngine(process)
    option.set_pricing_engine(engine)

    if calc == 'price':
        res = option.npv
    elif calc == 'delta':
        res = option.delta
    elif calc == 'gamma':
        res = option.gamma
    elif calc == 'theta':
        res = option.theta
    elif calc == 'rho':
        res = option.rho
    elif calc == 'vega':
        res = option.vega
    elif calc == 'lambda':
        res = option.delta * spot / option.npv
    else:
        raise ValueError('calc type %s is unknown' % calc)

    return res


def blsimpv(price, spot, strike, risk_free_rate, time,
            option_type=OptionType.Call, dividend=0.0):

    args = locals()
    the_shape, shape = common_shape(args)

    all_scalars = np.all([shape[key][0] == 'scalar' for key in shape])

    if all_scalars:
        res = _blsimpv(**args)
    else:
        res = array_call(_blsimpv, shape, args)

    return res


def _blsimpv(price, spot, strike, risk_free_rate, time,
             option_type, dividend):

    spot = SimpleQuote(spot)
    daycounter = ActualActual(ActualActual.ISMA)
    risk_free_ts = HandleYieldTermStructure(FlatForward(today(), risk_free_rate, daycounter))
    dividend_ts = HandleYieldTermStructure(FlatForward(today(), dividend, daycounter))
    volatility_ts = BlackConstantVol(today(), NullCalendar(),
                                     .3, daycounter)

    process = BlackScholesMertonProcess(spot, dividend_ts,
                                        risk_free_ts, volatility_ts)

    exercise_date = today() + Period(time * 365, Days)
    exercise = EuropeanExercise(exercise_date)

    payoff = PlainVanillaPayoff(option_type, strike)

    option = EuropeanOption(payoff, exercise)
    engine = AnalyticEuropeanEngine(process)
    option.set_pricing_engine(engine)

    accuracy = 0.001
    max_evaluations = 1000
    min_vol = 0.01
    max_vol = 2

    vol = option.implied_volatility(price, process,
            accuracy=accuracy,
            max_evaluations=max_evaluations,
            min_vol=min_vol,
            max_vol=max_vol)

    return vol
