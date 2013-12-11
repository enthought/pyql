"""
 Copyright (C) 2012, Enthought Inc
 Copyright (C) 2012, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import numpy as np
import quantlib.reference.names as nm

from quantlib.instruments.option import EuropeanExercise, VanillaOption
from quantlib.instruments.payoffs import PlainVanillaPayoff, Put, Call
from quantlib.models.equity.heston_model import HestonModel
from quantlib.pricingengines.vanilla.vanilla import AnalyticHestonEngine
from quantlib.processes.heston_process import HestonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.util.converter import pydate_to_qldate, df_to_zero_curve

from quantlib.instruments.api import EuropeanOption
from quantlib.pricingengines.api import AnalyticEuropeanEngine
from quantlib.processes.api import BlackScholesMertonProcess
from quantlib.termstructures.yields.api import FlatForward
from quantlib.termstructures.volatility.api import BlackConstantVol
from quantlib.time.api import Actual360, today, NullCalendar

from quantlib.time.date import (Period, Days)
from numbers import Number
import inspect


def heston_pricer(trade_date, options, params, rates, spot):
    """
    Price a list of European options with heston model.

    """

    spot = SimpleQuote(spot)

    risk_free_ts = df_to_zero_curve(rates[nm.INTEREST_RATE], trade_date)
    dividend_ts = df_to_zero_curve(rates[nm.DIVIDEND_YIELD], trade_date)

    process = HestonProcess(risk_free_ts, dividend_ts, spot, **params)

    model = HestonModel(process)
    engine = AnalyticHestonEngine(model, 64)

    settlement_date = pydate_to_qldate(trade_date)

    settings = Settings()
    settings.evaluation_date = settlement_date

    modeled_values = np.zeros(len(options))

    for index, row in options.T.iteritems():

        expiry_date = row[nm.EXPIRY_DATE]
        strike = row[nm.STRIKE]

        option_type = Call if row[nm.OPTION_TYPE] == nm.CALL_OPTION else Put

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


def common_shape(**args):

    the_shape = None
    res = {}
    for a in args:
        value = args[a]

        if isinstance(value, Number) or isinstance(value, basestring):
            res[a] = ('scalar', None)
        else:
            if(the_shape is None):
                the_shape = np.shape(value)
                res[a] = ('array', the_shape)
            elif(the_shape == np.shape(value)):
                res[a] = ('array', the_shape)
            else:
                raise ValueError('Wrong shape for argument %s. \
                Excepting a scalar or array of shape %s' % \
                                 (a, str(the_shape)))
    return res


def blsprice(spot, strike, risk_free_rate, time, volatility,
             option_type='Call', dividend=0.0):

    frame = inspect.currentframe()
    args, _, _, values = inspect.getargvalues(frame)

    # all non-scalar arguments must have the same shape, do not care if
    # it is a numpy type or not

    shape = common_shape(**values)

    all_scalars = np.all([shape[key][0] == 'scalar' for key in shape])

    if all_scalars:
        npv = _blsprice(**values)
    else:
        # the array and scalar variables
        array_vars = [k for k, v in shape.items() if v[0] == 'array']
        scalar_vars = [k for k, v in shape.items() if v[0] == 'scalar']
        the_shape = shape[array_vars[0]]
        npv = np.ravel(np.zeros(the_shape))
        for key in array_vars:
            values[key] = np.ravel(values[key])

        input_args = dict((key, 0) for key in args)
        for key in scalar_vars:
            input_args[key] = values[key]

        for i in range(len(npv)):
            for key in array_vars:
                input_args[key] = values[key][i]
            npv[i] = _blsprice(**input_args)

        npv = npv.reshape(the_shape)

    return npv


def _blsprice(spot, strike, risk_free_rate, time, volatility,
             option_type='Call', dividend=0.0):
    """
    Black-Scholes option pricing model.
    """
    spot = SimpleQuote(spot)

    daycounter = Actual360()
    risk_free_ts = FlatForward(today(), risk_free_rate, daycounter)
    dividend_ts = FlatForward(today(), dividend, daycounter)
    volatility_ts = BlackConstantVol(today(), NullCalendar(),
                                     volatility, daycounter)

    process = BlackScholesMertonProcess(spot, dividend_ts,
                                        risk_free_ts, volatility_ts)

    exercise_date = today() + Period(time * 365, Days)
    exercise = EuropeanExercise(exercise_date)

    payoff = PlainVanillaPayoff(option_type, strike)

    option = EuropeanOption(payoff, exercise)
    engine = AnalyticEuropeanEngine(process)
    option.set_pricing_engine(engine)
    return option.npv
