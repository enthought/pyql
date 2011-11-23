import unittest

from quantlib.time.api import Period, Months, TARGET, ModifiedFollowing
from quantlib.time.api import Actual365Fixed
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper

class RateHelpersTestCase(unittest.TestCase):

    def test_creation(self):
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
