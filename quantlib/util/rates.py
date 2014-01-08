"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

# Utility functions for handling interest rates
# ---------------------------------------------

import string
import re
import numpy as np

import quantlib
from quantlib.settings import Settings
from quantlib.termstructures.yields.rate_helpers import \
     DepositRateHelper, SwapRateHelper
from quantlib.time.api import (TARGET, Period, Months, Years, Days,
                               ModifiedFollowing, Unadjusted, Actual360,
                               Thirty360, Annual, ActualActual, ISDA,
                               JointCalendar, UnitedStates, UnitedKingdom,
                               NullCalendar)

from quantlib.currency import USDCurrency
from quantlib.quotes import SimpleQuote
from quantlib.util.converter import pydate_to_qldate, qldate_to_pydate
from quantlib.indexes.libor import Libor
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory

from quantlib.termstructures.yields.api import FlatForward, YieldTermStructure


_label_re_list = [ \
    # Swap
    re.compile("(SWAP)([0-9]{1,2})(Y)"),
    # Libor
    re.compile("(LIBOR)([1-9]{1,2})(M)")]


def _parse_rate_label(label):
    """
    Parse labels of the form
    Swap5Y
    Libor6M
    """

    label = string.lstrip(string.rstrip(label.upper()))
    for reg in _label_re_list:
        mo = reg.match(label)
        if mo != None:
            return (mo.group(1), int(mo.group(2)),
                    mo.group(3))

    raise Exception("couldn't parse label: %s" % label)


def make_rate_helper(label, rate, dt_obs, currency='USD'):
    """
    Wrapper for deposit and swaps rate helpers makers
    For Swaps: assume USD swap fixed rates vs. 6M Libor
    TODO: make this more general
    """

    if(currency.upper() != 'USD'):
        raise Exception("Only supported currency is USD.")

    rate_type, tenor, period = _parse_rate_label(label)

    if(~isinstance(dt_obs, quantlib.time.date.Date)):
        dt_obs = pydate_to_qldate(dt_obs)
    settings = Settings()
    calendar = JointCalendar(UnitedStates(), UnitedKingdom())
    # must be a business day
    eval_date = calendar.adjust(dt_obs)
    settings.evaluation_date = eval_date
    settlement_days = 2
    settlement_date = calendar.advance(eval_date, settlement_days, Days)
    # must be a business day
    settlement_date = calendar.adjust(settlement_date)
    end_of_month = True

    if((rate_type == 'SWAP') & (period == 'Y')):
        liborIndex = Libor('USD Libor', Period(6, Months),
                       settlement_days,
                       USDCurrency(), calendar,
                       Actual360(), YieldTermStructure(relinkable=False))
        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)
        helper = SwapRateHelper.from_tenor(rate,
                 Period(tenor, Years),
                 calendar, Annual,
                 Unadjusted, Thirty360(),
                 liborIndex, spread, fwdStart)
    elif((rate_type == 'LIBOR') & (period == 'M')):
        helper = DepositRateHelper(rate, Period(tenor, Months),
                 settlement_days,
                 calendar, ModifiedFollowing,
                 end_of_month,
                 Actual360())
    else:
        raise Exception("Rate type %s not supported" % label)

    return (helper)


def make_term_structure(rates, dt_obs):
    """
    rates is a dictionary-like structure with labels as keys
    and rates (decimal) as values.
    TODO: Make it more generic
    """

    settlement_date = pydate_to_qldate(dt_obs)
    rate_helpers = []
    for label in rates.keys():
        r = rates[label]
        h = make_rate_helper(label, r, settlement_date)
        rate_helpers.append(h)

    ts_day_counter = ActualActual(ISDA)
    tolerance = 1.0e-15
    ts = term_structure_factory('discount', 'loglinear',
         settlement_date, rate_helpers,
         ts_day_counter, tolerance)

    return ts


def zero_rate(term_structure, days, dt_settlement, calendar=TARGET()):
    """
    Compute zero-coupon rate, continuous ACT/365 from settlement date to given
    maturity expressed in calendar days
    Return
    - array of maturity dates
    - array of zero-coupon rates
    """

    dtMat = [calendar.advance(pydate_to_qldate(dt_settlement), d, Days)
             for d in days]
    df = np.array([term_structure.discount(dt) for dt in dtMat])
    dtMat = [qldate_to_pydate(dt) for dt in dtMat]
    dtToday = qldate_to_pydate(dt_settlement)
    dt = np.array([(d - dtToday).days / 365.0 for d in dtMat])
    zc = -np.log(df) / dt

    return (dtMat, zc)


def flat_rate(forward, daycounter):
    """
    Create a flat yield curve, with rate defined according
    to the specified day-count convention.
    Used mostly for unit tests and simple illustrations.
    """

    return FlatForward(
        forward=SimpleQuote(forward),
        settlement_days=0,
        calendar=NullCalendar(),
        daycounter=daycounter
    )
