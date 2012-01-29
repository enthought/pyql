import unittest

from quantlib.quotes import SimpleQuote
from quantlib.time.api import Period, Months, TARGET, ModifiedFollowing
from quantlib.time.api import Actual365Fixed
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper
from quantlib.termstructures.yields.rate_helpers import FraRateHelper

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


