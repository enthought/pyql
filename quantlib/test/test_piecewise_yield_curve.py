"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import unittest

from quantlib.currency import USDCurrency
from quantlib.settings import Settings
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper, SwapRateHelper
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory
from quantlib.time.api import Date, TARGET, Period, Months, Years, Days
from quantlib.time.api import September, ISDA, today, Mar
from quantlib.time.api import ModifiedFollowing, Unadjusted, Actual360
from quantlib.time.api import Thirty360, ActualActual, Actual365Fixed
from quantlib.time.api import Annual
from quantlib.quotes import SimpleQuote

from quantlib.indexes.libor import Libor

class PiecewiseYieldCurveTestCase(unittest.TestCase):

    def test_creation(self):

        settings = Settings()

        # Market information
        calendar = TARGET()

        # must be a business day
        settings.evaluation_date = calendar.adjust(today())

        settlement_date = Date(18, September, 2008)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date);

        quotes = [0.0096, 0.0145, 0.0194]
        tenors =  [3, 6, 12]

        rate_helpers = []

        calendar =  TARGET()
        deposit_day_counter = Actual365Fixed()
        convention = ModifiedFollowing
        end_of_month = True

        for quote, month in zip(quotes, tenors):
            tenor = Period(month, Months)
            fixing_days = 3

            helper = DepositRateHelper(
                quote, tenor, fixing_days, calendar, convention, end_of_month,
                deposit_day_counter
            )

            rate_helpers.append(helper)


        ts_day_counter = ActualActual(ISDA)

        tolerance = 1.0e-15

        ts = term_structure_factory(
            'discount', 'loglinear', settlement_date, rate_helpers,
            ts_day_counter, tolerance
        )

        self.assertIsNotNone(ts)

        self.assertEquals( Date(18, September, 2008), ts.reference_date)

        # this is not a real test ...
        self.assertAlmostEquals(0.9975, ts.discount(Date(21, 12, 2008)), 4)
        self.assertAlmostEquals(0.9944, ts.discount(Date(21, 4, 2009)), 4)
        self.assertAlmostEquals(0.9904, ts.discount(Date(21, 9, 2009)), 4)

    def test_deposit_swap(self):

        settings = Settings()

        # Market information
        calendar = TARGET()

        todays_date = Date(1, Mar, 2012)

        # must be a business day
        eval_date = calendar.adjust(todays_date)
        settings.evaluation_date = eval_date

        settlement_days = 2
        settlement_date = calendar.advance(eval_date, settlement_days, Days)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date);

        depositData = [[ 1, Months, 4.581 ],
                       [ 2, Months, 4.573 ],
                       [ 3, Months, 4.557 ],
                       [ 6, Months, 4.496 ],
                       [ 9, Months, 4.490 ]]

        swapData = [[ 1, Years, 4.54 ],
                    [ 5, Years, 4.99 ],
                    [ 10, Years, 5.47 ],
                    [ 20, Years, 5.89 ],
                    [ 30, Years, 5.96 ]]

        rate_helpers = []

        end_of_month = True

        for m, period, rate in depositData:
            tenor = Period(m, Months)

            helper = DepositRateHelper(rate/100, tenor, settlement_days,
                     calendar, ModifiedFollowing, end_of_month,
                     Actual360())

            rate_helpers.append(helper)

        liborIndex = Libor('USD Libor', Period(6, Months), settlement_days,
                           USDCurrency(), calendar, Actual360())

        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)

        for m, period, rate in swapData:

            helper = SwapRateHelper.from_tenor(
                rate/100, Period(m, Years), calendar, Annual, Unadjusted, Thirty360(), liborIndex,
                spread, fwdStart
            )

            rate_helpers.append(helper)

        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-15

        ts = term_structure_factory(
            'discount', 'loglinear', settlement_date, rate_helpers,
            ts_day_counter, tolerance)

        # this is not a real test ...
        self.assertAlmostEquals(0.9103,
             ts.discount(calendar.advance(todays_date, 2, Years)),3)
        self.assertAlmostEquals(0.7836,
             ts.discount(calendar.advance(todays_date, 5, Years)),3)
        self.assertAlmostEquals(0.5827,
             ts.discount(calendar.advance(todays_date, 10, Years)),3)
        self.assertAlmostEquals(0.4223,
             ts.discount(calendar.advance(todays_date, 15, Years)),3)


if __name__ == '__main__':
    unittest.main()
