from .unittest_tools import unittest

from quantlib.settings import Settings

from quantlib.currency.api import USDCurrency
from quantlib.indexes.ibor.libor import Libor
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.rate_helpers import (
    DepositRateHelper, SwapRateHelper)
from quantlib.termstructures.yields.api import (
    PiecewiseYieldCurve, BootstrapTrait, Interpolator )

from quantlib.time.api import (
    Period, Months, Date, Days, TARGET, ModifiedFollowing,
    Years, Actual360, Semiannual,
    Thirty360, ActualActual, ISDA
)

from datetime import date
from quantlib.util.converter import pydate_to_qldate


def build_helpers():
        calendar = TARGET()
        settlement_days = 2

        depositData = [[1, Months, 'Libor1M', 5.32],
                       [3, Months, 'Libor3M', 5.35],
                       [6, Months, 'Libor6M', 5.35]]

        swapData = [[1, Years, 'Swap1Y', 5.31],
                    [2, Years, 'Swap2Y', 5.06],
                    [3, Years, 'Swap3Y', 5.00],
                    [4, Years, 'Swap4Y', 5.01],
                    [5, Years, 'Swap5Y', 5.04],
                    [7, Years, 'Swap7Y', 5.12],
                    [10, Years, 'Swap10Y', 5.22],
                    [30, Years, 'Swap30Y', 5.44]]

        rate_helpers = []

        end_of_month = True

        for m, _, _, rate in depositData:
            tenor = Period(m, Months)
            helper = DepositRateHelper(SimpleQuote(rate / 100.0), tenor,
                                       settlement_days,
                                       calendar, ModifiedFollowing,
                                       end_of_month,
                                       Actual360())

        rate_helpers.append(helper)

        liborIndex = Libor('USD Libor', Period(3, Months),
                           settlement_days,
                           USDCurrency(), calendar,
                           Actual360())

        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)

        for m, _, _, rate in swapData:
            helper = SwapRateHelper.from_tenor(
                SimpleQuote(rate / 100.0),
                Period(m, Years),
                calendar, Semiannual,
                ModifiedFollowing, Thirty360(),
                liborIndex, spread, fwdStart)

        rate_helpers.append(helper)

        return rate_helpers

class ZeroCouponTestCase(unittest.TestCase):

    def test_extrapolation(self):
        rate_helpers = build_helpers()
        settings = Settings()

        calendar = TARGET()

        # must be a business Days
        dtObs = date(2007, 4, 27)
        eval_date = calendar.adjust(pydate_to_qldate(dtObs))
        settings.evaluation_date = eval_date

        settlement_days = 2
        settlement_date = calendar.advance(eval_date, settlement_days, Days)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date)

        print('dt Obs: %s\ndt Eval: %s\ndt Settle: %s' %
              (dtObs, eval_date, settlement_date))
        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-2

        ts = PiecewiseYieldCurve.from_reference_date(BootstrapTrait.Discount,
                                 Interpolator.LogLinear,
                                 settlement_date,
                                 rate_helpers,
                                 ts_day_counter,
                                 tolerance)

        # max_date raises an exception without extrapolaiton...
        self.assertFalse(ts.extrapolation)
        with self.assertRaises(RuntimeError) as ctx:
            ts.discount(ts.max_date + 1)
        self.assertTrue(str(ctx.exception) in (
            "time (30.011) is past max curve time (30.0082)",
            "1st iteration: failed at 2nd alive instrument"))

    def test_zero_curve(self):
        rate_helpers = build_helpers()
        settings = Settings()

        calendar = TARGET()

        # must be a business Days
        dtObs = date(2007, 4, 27)
        eval_date = calendar.adjust(pydate_to_qldate(dtObs))
        settings.evaluation_date = eval_date

        settlement_days = 2
        settlement_date = calendar.advance(eval_date, settlement_days, Days)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date)

        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-2

        ts = PiecewiseYieldCurve.from_reference_date(BootstrapTrait.Discount,
                                 Interpolator.LogLinear,
                                 settlement_date,
                                 rate_helpers,
                                 ts_day_counter,
                                 tolerance)

        # max_date raises an exception...
        ts.extrapolation = True
        zr = ts.zero_rate(Date(10, 5, 2027), ts_day_counter, 2)
        self.assertAlmostEqual(zr.rate, 0.0539332, 6)

if __name__ == '__main__':
    unittest.main()
