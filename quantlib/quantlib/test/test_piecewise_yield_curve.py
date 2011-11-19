import unittest

from quantlib.termstructures.yields.rate_helpers import DepositRateHelper
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory
from quantlib.time.api import Date, TARGET, Period, Months
from quantlib.time.api import ModifiedFollowing, Actual365Fixed, ActualActual
from quantlib.time.api import September, ISDA

class PiecewiseYieldCurveTestCase(unittest.TestCase):

    def test_creation(self):

        # Market information
        calendar = TARGET()

        settlement_date = Date(18, September, 2008)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date);


        quotes = [0.0096, 0.0145, 0.0194]
        tenors =  [3, 6, 12]

        rate_helpers = []

        for quote, tenor in zip(quotes, tenors):
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

            rate_helpers.append(helper)


        ts_day_counter = ActualActual(ISDA)

        tolerance = 1.0e-15

        ts = term_structure_factory(
            'discount', 'loglinear', settlement_date, rate_helpers,
            ts_day_counter, tolerance
        )

        self.assertIsNotNote(ts)

        print 'XXXXXX'



if __name__ == '__main__':
    unittest.main()
