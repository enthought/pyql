from .unittest_tools import unittest

from quantlib.currency.api import USDCurrency
from quantlib.indexes.swap_index import SwapIndex
from quantlib.indexes.ibor.libor import Libor
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.rate_helpers import (
    DepositRateHelper, FraRateHelper, FuturesRateHelper, SwapRateHelper
)
from quantlib.termstructures.yields.api import YieldTermStructure
from quantlib.time.api import (
    Period, Months, TARGET, ModifiedFollowing, Actual365Fixed, Date, Years,
    UnitedStates, Actual360, Annual
)
from quantlib.settings import Settings

class RateHelpersTestCase(unittest.TestCase):

    def test_create_deposit_rate_helper(self):

        quote = SimpleQuote(0.0096)
        tenor = Period(3, Months)
        fixing_days = 3
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        deposit_day_counter = Actual365Fixed()


        helper_from_quote = DepositRateHelper(
            quote, tenor, fixing_days, calendar, convention, end_of_month,
            deposit_day_counter
        )

        ## create helper from float directly
        helper_from_float = DepositRateHelper(
            0.0096, tenor, fixing_days, calendar, convention, end_of_month,
            deposit_day_counter
        )
        self.assertIsNotNone(helper_from_quote, helper_from_float)
        self.assertEqual(quote.value, helper_from_quote.quote)
        self.assertEqual(helper_from_quote.quote, helper_from_float.quote)

    def test_relativedate_rate_helper(self):
        tenor = Period(3, Months)
        fixing_days = 3
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        deposit_day_counter = Actual365Fixed()

        helper = DepositRateHelper(
            0.005, tenor, fixing_days, calendar, convention, end_of_month,
            deposit_day_counter
        )
        Settings.instance().evaluation_date = Date(8, 6, 2016)
        self.assertEqual(helper.latest_date, Date(13, 9, 2016))

    def test_deposit_end_of_month(self):
        tenor = Period(3, Months)
        fixing_days = 0
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        deposit_day_counter = Actual365Fixed()

        helper_end_of_month = DepositRateHelper(
            0.005, tenor, fixing_days, calendar, convention, True,
            deposit_day_counter
        )
        helper_no_end_of_month = DepositRateHelper(
            0.005, tenor, fixing_days, calendar, convention, False,
            deposit_day_counter
        )
        Settings.instance().evaluation_date = Date(29, 2, 2016)
        self.assertEqual(helper_end_of_month.latest_date, Date(31, 5, 2016))
        self.assertEqual(helper_no_end_of_month.latest_date, Date(30, 5, 2016))



    def test_create_fra_rate_helper(self):

        quote = SimpleQuote(0.0096)
        month_to_start = 3
        month_to_end = 9
        fixing_days = 2
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        day_counter = Actual365Fixed()


        helper_from_quote = FraRateHelper(
            quote, month_to_start, month_to_end, fixing_days, calendar,
            convention, end_of_month, day_counter
        )
        helper_from_float = FraRateHelper(
            0.0096, month_to_start, month_to_end, fixing_days, calendar,
            convention, end_of_month, day_counter
        )
        self.assertIsNotNone(helper_from_float, helper_from_quote)
        self.assertEqual(quote.value, helper_from_quote.quote)
        self.assertEqual(helper_from_quote.quote, helper_from_float.quote)

    def test_create_futures_rate_helper(self):

        quote = SimpleQuote(0.0096)
        imm_date = Date(19, 12, 2001)
        length_in_months = 9
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        day_counter = Actual365Fixed()


        helper_from_quote = FuturesRateHelper(
            quote, imm_date, length_in_months, calendar,
            convention, end_of_month, day_counter
        )
        helper_from_float = FuturesRateHelper(
            0.0096, imm_date, length_in_months, calendar,
            convention, end_of_month, day_counter
        )

        self.assertIsNotNone(helper_from_float, helper_from_quote)
        self.assertEqual(quote.value, helper_from_quote.quote)
        self.assertEqual(helper_from_quote.quote, helper_from_float.quote)

    def test_create_swap_rate_helper_no_classmethod(self):

        with self.assertRaises(ValueError):
            SwapRateHelper()


    def test_create_swap_rate_helper_from_index(self):
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

        rate = SimpleQuote(0.005681)
        tenor = Period(1, Years)

        index = SwapIndex (
            family_name, tenor, settlement_days, currency, calendar,
            fixed_leg_tenor, fixed_leg_convention,
            fixed_leg_daycounter, ibor_index)

        helper_from_quote = SwapRateHelper.from_index(rate, index)
        helper_from_float = SwapRateHelper.from_index(0.005681, index)

        #self.fail(
        #    'Make this pass: create and ask for the .quote property'
        #    ' Test the from_index and from_tenor methods'
        #)

        self.assertIsNotNone(helper_from_quote, helper_from_float)
        self.assertAlmostEqual(rate.value, helper_from_quote.quote)
        self.assertAlmostEqual(helper_from_float.quote, helper_from_quote.quote)

        with self.assertRaises(RuntimeError):
            self.assertAlmostEqual(rate.value, helper_from_quote.implied_quote)

    def test_create_swap_rate_helper_from_tenor(self):
        calendar = UnitedStates()
        settlement_days = 2

        rate = SimpleQuote(0.005681)

        ibor_index =  Libor(
            "USDLibor", Period(3,Months), settlement_days, USDCurrency(),
            UnitedStates(), Actual360())
        helper_from_quote = SwapRateHelper.from_tenor(rate, Period(12, Months), calendar,
                                            Annual, ModifiedFollowing, Actual360(),
                                            ibor_index)
        helper_from_float =  SwapRateHelper.from_tenor(0.005681, Period(12, Months), calendar,
                                            Annual, ModifiedFollowing, Actual360(),
                                            ibor_index)

        self.assertIsNotNone(helper_from_float, helper_from_quote)
        self.assertEqual(rate.value, helper_from_quote.quote)
        self.assertEqual(helper_from_quote.quote, helper_from_float.quote)

        with self.assertRaises(RuntimeError):
            self.assertAlmostEqual(rate.value, helper_from_quote.implied_quote)

if __name__ == '__main__':
    unittest.main()
