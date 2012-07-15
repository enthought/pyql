"""
 Copyright (C) 2012, Enthought Inc
 Copyright (C) 2012, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""


import numpy as np
from pandas import DataFrame

from quantlib.instruments.option import (
            Put, Call, EuropeanExercise, VanillaOption)
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.models.equity.heston_model import HestonModel
from quantlib.pricingengines.vanilla import AnalyticHestonEngine
from quantlib.processes.heston_process import HestonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.util.converter import pydate_to_qldate, df_to_zero_curve


# Dataframe column names - Global constants
EXPIRY = 'dtExpiry'
TRADE_DATE = 'dtTrade'
SPOT = 'Spot'
OPTION_TYPE = 'Type'
BID = 'PBid'
ASK = 'PAsk'
STRIKE = 'Strike'
INTEREST_RATE = 'iRate'
DIVIDEND_YIELD = 'dRate'
PRICE = 'Price'


# Dataframe colum names - local constants
CALL_PREMIUM = 'PremiumC'
PUT_PREMIUM = 'PremiumP'

# Other constants
CALL_OPTION = 'C'
PUT_OPTION = 'P'

def options_to_rates(options, t_min=1./12., n_min=6):
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

    grouped = options.groupby(EXPIRY)

    expiry_dates = []
    implied_interest_rates = []
    implied_dividend_yields = []


    for spec, group in grouped:
        # implied vol for this type/expiry group

        index = group.index

        trade_date = group[TRADE_DATE][index[0]]
        expiry_date = group[EXPIRY][index[0]]
        spot = group[SPOT][index[0]]
        days_to_expiry = (expiry_date-trade_date).days
        time_to_maturity = days_to_expiry/365.0

        # exclude groups with too short time to maturity
        if time_to_maturity < t_min:
            continue

        # extract the put and call quotes
        calls = group[group[OPTION_TYPE] == CALL_OPTION]
        puts = group[group[OPTION_TYPE] == PUT_OPTION]

        # exclude groups with too few data points
        if (len(calls) < n_min) | (len(puts) < n_min):
            continue

        # calculate forward, implied interest rate and implied div. yield
        call_premium = DataFrame(
            (calls[BID] + calls[ASK]) / 2.,
            columns=[CALL_PREMIUM]
        )
        call_premium.index = calls[STRIKE]

        put_premium = DataFrame(
            (puts[BID] + puts[ASK]) / 2.,
            columns=[PUT_PREMIUM]
        )
        put_premium.index = puts[STRIKE]

        # use 'inner' join because some strikes are not quoted for C and P
        all_quotes = call_premium.join(put_premium, how='inner')
        all_quotes[STRIKE] = all_quotes.index
        all_quotes['C-P'] = all_quotes[CALL_PREMIUM] - all_quotes[PUT_PREMIUM]

        y = np.array(all_quotes['C-P'])
        x = np.array(all_quotes[STRIKE])
        A = np.vstack([x, np.ones(len(x))]).T
        m, c = np.linalg.lstsq(A, y)[0]

        # intercept is last coef
        interest_rate = -np.log(-m)/time_to_maturity
        dividend_yield = np.log(spot/c)/time_to_maturity

        implied_interest_rates.append(interest_rate)
        implied_dividend_yields.append(dividend_yield)
        expiry_dates.append(expiry_date)

    rates = DataFrame(
        {
            INTEREST_RATE: implied_interest_rates,
            DIVIDEND_YIELD: implied_dividend_yields
        },
        index=expiry_dates
    )

    return rates

def heston_pricer(trade_date, options, params, rates, spot):
    """ Price a list of European options with heston model.

    """

    spot = SimpleQuote(spot)

    risk_free_ts = df_to_zero_curve(rates[INTEREST_RATE], trade_date)
    dividend_ts = df_to_zero_curve(rates[DIVIDEND_YIELD], trade_date)

    process = HestonProcess(risk_free_ts, dividend_ts, spot, **params)

    model = HestonModel(process)
    engine = AnalyticHestonEngine(model, 64)

    settlement_date = pydate_to_qldate(trade_date)

    settings = Settings()
    settings.evaluation_date = settlement_date

    modeled_values = np.zeros(len(options))

    for index, row in options.T.iteritems():

        expiry_date = row[EXPIRY]
        strike = row[STRIKE]

        cp = Call if row[OPTION_TYPE] == CALL_OPTION else Put

        payoff = PlainVanillaPayoff(cp, strike)

        expiry_qldate = pydate_to_qldate(expiry_date)
        exercise = EuropeanExercise(expiry_qldate)

        option = VanillaOption(payoff, exercise)
        option.set_pricing_engine(engine)

        modeled_values[index] = option.net_present_value

    prices = options.filter(items=[EXPIRY, STRIKE, OPTION_TYPE, SPOT])
    prices[PRICE] = modeled_values
    prices[TRADE_DATE] = trade_date

    return prices
