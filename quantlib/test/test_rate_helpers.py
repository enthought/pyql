import unittest

from quantlib.quotes import SimpleQuote
from quantlib.time.api import Period, Months, TARGET, ModifiedFollowing
from quantlib.time.api import Actual365Fixed, Date
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper
from quantlib.termstructures.yields.rate_helpers import FraRateHelper
from quantlib.termstructures.yields.rate_helpers import FuturesRateHelper
from quantlib.termstructures.yields.rate_helpers import SwapRateHelper

class RateHelpersTestCase(unittest.TestCase):

    def test_create_deposit_rate_helper(self):

        quote = 0.0096
        tenor = Period(3, Months)
        fixing_days = 3
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        deposit_day_counter = Actual365Fixed()


        helper = DepositRateHelper(
            quote, tenor, fixing_days, calendar, convention, end_of_month,
            deposit_day_counter
        )

        self.assertIsNotNone(helper)
        self.assertEquals(quote, helper.quote)


    def test_create_fra_rate_helper(self):

        quote = SimpleQuote(0.0096)
        month_to_start = 3
        month_to_end = 9
        fixing_days = 2
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        day_counter = Actual365Fixed()


        helper = FraRateHelper(
            quote, month_to_start, month_to_end, fixing_days, calendar,
            convention, end_of_month, day_counter
        )

        self.assertIsNotNone(helper)
        self.assertEquals(quote.value, helper.quote)

    def test_create_futures_rate_helper(self):

        quote = SimpleQuote(0.0096)
        imm_date = Date(19, 12, 2001)
        length_in_months = 9
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        day_counter = Actual365Fixed()


        helper = FuturesRateHelper(
            quote, imm_date, length_in_months, calendar,
            convention, end_of_month, day_counter
        )

        self.assertIsNotNone(helper)
        self.assertEquals(quote.value, helper.quote)


    def test_create_swap_rate_helper_no_classmethod(self):

        with self.assertRaises(ValueError):
            SwapRateHelper()


    def test_create_swap_rate_helper_from_index(self):

        from quantlib.currency import USDCurrency
        from quantlib.indexes.swap_index import SwapIndex
        from quantlib.indexes.libor import Libor
        from quantlib.time.api import Years, UnitedStates, Actual360

        calendar = UnitedStates()
        settlement_days = 2
        currency = USDCurrency()
        fixed_leg_tenor	= Period(12, Months)
        fixed_leg_convention = ModifiedFollowing
        fixed_leg_daycounter = Actual360()
        family_name = currency.name + 'index'
        ibor_index =  Libor(
            "USDLibor", Period(3,Months), settlement_days, USDCurrency(),
            UnitedStates(), Actual360()
        )

        rate = 0.005681
        tenor = Period(1, Years)

        index = SwapIndex (
            family_name, tenor, settlement_days, currency, calendar,
            fixed_leg_tenor, fixed_leg_convention,
            fixed_leg_daycounter, ibor_index)

        helper = SwapRateHelper.from_index(rate, index)

        #self.fail(
        #    'Make this pass: create and ask for the .quote property'
        #    ' Test the from_index and from_tenor methods'
        #)

        self.assertIsNotNone(helper)
        self.assertAlmostEquals(rate, helper.quote)

        with self.assertRaises(RuntimeError):
            self.assertAlmostEquals(rate, helper.implied_quote)

if __name__ == '__main__':
    unittest.main()
