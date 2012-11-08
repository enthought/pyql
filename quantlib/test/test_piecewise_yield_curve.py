"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import unittest

from quantlib.currency import USDCurrency
from quantlib.indexes.swap_index import SwapIndex
from quantlib.settings import Settings
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper, SwapRateHelper
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory, VALID_TRAITS, VALID_INTERPOLATORS, PiecewiseYieldCurve
from quantlib.time.api import Date, TARGET, Period, Months, Years, Days
from quantlib.time.api import September, ISDA, today, Mar
from quantlib.time.api import ModifiedFollowing, Unadjusted, Actual360
from quantlib.time.api import Thirty360, ActualActual, Actual365Fixed
from quantlib.time.api import Annual, UnitedStates, today
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

    def test_all_types_of_piecewise_curves(self):

        settings = Settings()

        # Market information
        calendar = TARGET()

        todays_date = Date(12, September, 2008)
        # must be a business day
        settings.evaluation_date = calendar.adjust(todays_date)

        settlement_date = Date(18, September, 2008)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date);

        quotes = [0.0096, 0.0145, 0.0194]
        tenors =  [3, 6, 12]

        rate_helpers = []

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


        tolerance = 1.0e-15 

        for trait in VALID_TRAITS:
            for interpolation in VALID_INTERPOLATORS:
                ts = PiecewiseYieldCurve(
                    trait, interpolation, settlement_date, rate_helpers,
                    deposit_day_counter, tolerance
                )

                self.assertIsNotNone(ts)
                self.assertEquals( Date(18, September, 2008), ts.reference_date)


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

        self.assertEquals(settlement_date, ts.reference_date)

        # this is not a real test ...
        self.assertAlmostEquals(0.9103,
             ts.discount(calendar.advance(todays_date, 2, Years)),3)
        self.assertAlmostEquals(0.7836,
             ts.discount(calendar.advance(todays_date, 5, Years)),3)
        self.assertAlmostEquals(0.5827,
             ts.discount(calendar.advance(todays_date, 10, Years)),3)
        self.assertAlmostEquals(0.4223,
             ts.discount(calendar.advance(todays_date, 15, Years)),3)


    #@unittest.skip('This segfaults')
    def test_zero_curve_on_swap_index(self):

        todays_date = today()

        calendar = UnitedStates() # INPUT
        dayCounter = Actual360() # INPUT
        currency = USDCurrency() # INPUT	

        Settings.instance().evaluation_date = todays_date
        settlement_days	= 2

        settlement_date =  calendar.advance(
            todays_date, period=Period(settlement_days, Days)
        )

        liborRates = [ 0.002763, 0.004082, 0.005601, 0.006390, 0.007125, 0.007928, 0.009446,
            0.01110]
        liborRatesTenor = [Period(tenor, Months) for tenor in [1,2,3,4,5,6,9,12]]
        Libor_dayCounter = Actual360();


        swapRates = [0.005681, 0.006970, 0.009310, 0.012010, 0.014628, 0.016881, 0.018745,
                 0.020260, 0.021545]
        swapRatesTenor = [Period(i, Years) for i in range(2, 11)]
        # description of the fixed leg of the swap
        Swap_fixedLegTenor	= Period(12, Months) # INPUT
        Swap_fixedLegConvention = ModifiedFollowing # INPUT
        Swap_fixedLegDayCounter = Actual360() # INPUT
        # description of the float leg of the swap
        Swap_iborIndex =  Libor(
            "USDLibor", Period(3,Months), settlement_days, USDCurrency(),
            UnitedStates(), Actual360()
        )

        SwapFamilyName = currency.name + "swapIndex"
        instruments = []

        # ++++++++++++++++++++ Creation of the vector of RateHelper (need for the Yield Curve construction)
        # ++++++++++++++++++++ Libor 
        LiborFamilyName = currency.name + "Libor"
        instruments = []
        for rate, tenor in zip(liborRates, liborRatesTenor):
            # Index description ___ creation of a Libor index
            liborIndex =  Libor(LiborFamilyName, tenor, settlement_days, currency, calendar,
                    Libor_dayCounter)
            # Initialize rate helper	___ the DepositRateHelper link the recording rate with the Libor index													
            instruments.append(DepositRateHelper(rate, index=liborIndex))


        for tenor, rate in zip(swapRatesTenor, swapRates):
            # swap description ___ creation of a swap index. The floating leg is described in the index 'Swap_iborIndex'
            swapIndex = SwapIndex (SwapFamilyName, tenor, settlement_days, currency, calendar,
                    Swap_fixedLegTenor, Swap_fixedLegConvention, Swap_fixedLegDayCounter,
                    Swap_iborIndex)
            # Initialize rate helper __ the SwapRateHelper links the swap index width his rate
            instruments.append(SwapRateHelper.from_index(rate,swapIndex))

        # ++++++++++++++++++  Now the creation of the yield curve

        tolerance = 1.0e-15

        ts = term_structure_factory(
            'zero', 'linear', settlement_date, instruments, dayCounter, tolerance
        )

        self.assertEquals(settlement_date, ts.reference_date)

if __name__ == '__main__':
    unittest.main()
