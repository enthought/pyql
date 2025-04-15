"""
 Copyright (C) 2012, Enthought Inc
 Copyright (C) 2012, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import numpy as np
import quantlib.reference.names as nm
import quantlib.reference.data_structures as ds
from pandas import DataFrame

from quantlib.instruments.option import VanillaOption
from quantlib.instruments.exercise import EuropeanExercise
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import OptionType
from quantlib.models.equity.heston_model import HestonModel
from quantlib.processes.heston_process import HestonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.util.converter import pydate_to_qldate, df_to_zero_curve

from quantlib.instruments.api import EuropeanOption
from quantlib.pricingengines.api import AnalyticEuropeanEngine, AnalyticHestonEngine
from quantlib.processes.api import BlackScholesMertonProcess
from quantlib.termstructures.yields.api import FlatForward
from quantlib.termstructures.volatility.api import BlackConstantVol
from quantlib.time.api import Actual360, today, NullCalendar


def options_to_rates(options, t_min=1. / 12., n_min=6):
    """
    Extract implied risk-free rates and dividend yield from
    standard European option quote file.

    ignore data:
    - with time to maturity < tMin (in fraction of years)
    - with fewer than nMin quotes per maturity date

    Parameters
    ----------

    t_min: float (default: 1 month)
        Minimum time to maturity in fraction of years
    n_min: int (default: 6)
        minimum number of quotes per maturity date

    """

    grouped = options.groupby(nm.EXPIRY_DATE)

    expiry_dates = []
    implied_interest_rates = []
    implied_dividend_yields = []

    for spec, group in grouped:
        # implied vol for this type/expiry group

        index = group.index

        trade_date = group[nm.TRADE_DATE][index[0]]
        expiry_date = group[nm.EXPIRY_DATE][index[0]]
        spot = group[nm.SPOT][index[0]]
        days_to_expiry = (expiry_date - trade_date).days
        time_to_maturity = days_to_expiry / 365.0

        # exclude groups with too short time to maturity
        if time_to_maturity < t_min:
            continue

        # extract the put and call quotes
        calls = group[group[nm.OPTION_TYPE] == nm.CALL_OPTION]
        puts = group[group[nm.OPTION_TYPE] == nm.PUT_OPTION]

        # exclude groups with too few data points
        if (len(calls) < n_min) | (len(puts) < n_min):
            continue

        # calculate forward, implied interest rate and implied div. yield
        call_premium = DataFrame(
            (calls[nm.PRICE_BID] + calls[nm.PRICE_ASK]) / 2.,
            columns=[CALL_PREMIUM])
        call_premium.index = np.array(calls[nm.STRIKE])

        put_premium = DataFrame(
            (puts[nm.PRICE_BID] + puts[nm.PRICE_ASK]) / 2.,
            columns=[PUT_PREMIUM])
        put_premium.index = np.array(puts[nm.STRIKE])

        # use 'inner' join because some strikes are not quoted for C and P
        all_quotes = call_premium.join(put_premium, how='inner')
        all_quotes[nm.STRIKE] = all_quotes.index
        all_quotes['C-P'] = all_quotes[CALL_PREMIUM] - all_quotes[PUT_PREMIUM]

        y = np.array(all_quotes['C-P'])
        x = np.array(all_quotes[nm.STRIKE])
        A = np.vstack([x, np.ones(len(x))]).T
        a_1, a_0 = np.linalg.lstsq(A, y)[0]

        # intercept is last coef
        interest_rate = -np.log(-a_1) / time_to_maturity
        dividend_yield = np.log(spot / a_0) / time_to_maturity

        implied_interest_rates.append(interest_rate)
        implied_dividend_yields.append(dividend_yield)
        expiry_dates.append(expiry_date)

    rates = ds.riskfree_dividend_template().reindex(index=expiry_dates)
    rates[nm.INTEREST_RATE] = implied_interest_rates
    rates[nm.DIVIDEND_YIELD] = implied_dividend_yields

    return rates


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
