"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from datetime import datetime

import numpy as np
import matplotlib.pyplot as plt
import pandas

from quantlib.settings import Settings
from quantlib.termstructures.yields.rate_helpers import (DepositRateHelper,
                                                         SwapRateHelper)
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory
from quantlib.time.api import TARGET, Period, Months, Years, Days
from quantlib.time.api import (ModifiedFollowing, Unadjusted, Actual360,
                               Thirty360, ActualActual)

from quantlib.time.api import ISDA, today
from quantlib.currency import USDCurrency

from quantlib.indexes.libor import Libor
from quantlib.time.date import Annual


def get_term_structure(df_libor, dtObs):

    settings = Settings()

    # Market information
    calendar = TARGET()

    # must be a business day
    eval_date = calendar.adjust(today())
    settings.evaluation_date = eval_date

    settlement_days = 2
    settlement_date = calendar.advance(eval_date, settlement_days, Days)
    # must be a business day
    settlement_date = calendar.adjust(settlement_date)

    depositData = [[1, Months, 'Libor1M'],
                  [3, Months, 'Libor3M'],
                  [6, Months, 'Libor6M']]

    swapData = [[1, Years, 'Swap1Y'],
                [2, Years, 'Swap2Y'],
                [3, Years, 'Swap3Y'],
                [4, Years, 'Swap4Y'],
                [5, Years, 'Swap5Y'],
                [7, Years, 'Swap7Y'],
                [10, Years, 'Swap10Y'],
                [30, Years, 'Swap30Y']]

    rate_helpers = []

    end_of_month = True

    for m, period, label in depositData:
        tenor = Period(m, Months)
        rate = df_libor[label][dtObs]
        helper = DepositRateHelper(float(rate / 100), tenor,
                 settlement_days,
                 calendar, ModifiedFollowing, end_of_month,
                 Actual360())

        rate_helpers.append(helper)

    liborIndex = Libor('USD Libor', Period(6, Months),
                       settlement_days,
                       USDCurrency(), calendar,
                       Actual360())

    for m, period, label in swapData:
        rate = df_libor.get_value(dtObs, label)
        helper = SwapRateHelper.from_tenor(rate / 100,
                 Period(m, Years),
            calendar, Annual,
            Unadjusted, Thirty360(),
            liborIndex)

        rate_helpers.append(helper)

    ts_day_counter = ActualActual(ISDA)
    tolerance = 1.0e-15

    ts = term_structure_factory(
        'discount', 'loglinear', settlement_date, rate_helpers,
        ts_day_counter, tolerance)

    return ts


def QLDateTodate(dt):
    """
    Converts a QL Date to a datetime
    """

    return datetime(dt.year, dt.month, dt.day)


def zero_curve(ts):
    calendar = TARGET()
    days = range(10, 365 * 20, 30)
    dtMat = [calendar.advance(today(), d, Days) for d in days]
    df = np.array([ts.discount(dt) for dt in dtMat])
    dtMat = [QLDateTodate(dt) for dt in dtMat]
    dtToday = QLDateTodate(today())
    dt = np.array([(d - dtToday).days / 365.0 for d in dtMat])
    zc = -np.log(df) / dt
    return (dtMat, zc)

if __name__ == '__main__':

    df_libor = pandas.load('data/df_libor.pkl')

    dtObs = datetime(2011, 12, 20)

    ts = get_term_structure(df_libor, dtObs)

    (dtMat, zc) = zero_curve(ts)

    plt.plot(dtMat, zc)
