from .unittest_tools import unittest

from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.bond_helpers import (
    FixedRateBondHelper)
from quantlib.time.api import (
    Annual, Rule, Date, DayCounter, ModifiedFollowing, Following, Period, Schedule, TARGET)

class TestFixedRateBondHelper(unittest.TestCase):

    def test_create_fixed_rate_bond_helper(self):

        issue_date = Date(20, 3, 2014)
        maturity = Date(20, 3, 2019)

        schedule = Schedule(
            issue_date,
            maturity,
            Period(Annual),
            TARGET(),
            ModifiedFollowing,
            ModifiedFollowing,
            Rule.Backward,
            False
        )

        clean_price = 71.23
        settlement_days = 3
        rates = [0.035]

        daycounter = DayCounter.from_name("Actual/Actual (Bond)")
        helper = FixedRateBondHelper(
            SimpleQuote(clean_price),
            settlement_days,
            100.0,
            schedule,
            rates,
            daycounter,
            Following,
            100.0,
            issue_date)

        self.assertEqual(helper.quote, clean_price)


if __name__ == '__main__':
    unittest.main()
