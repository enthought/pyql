import unittest

from quantlib.time.api import (
    Period, Months, Years, Following, Actual365Fixed,
    UnitedStates, today, Unadjusted)
from quantlib.math.matrix import Matrix
import numpy as np
from quantlib.termstructures.volatility.swaption.swaption_vol_matrix \
    import SwaptionVolatilityMatrix
from quantlib.indexes.api import IborIndex, SwapIndex, Euribor6M
from quantlib.termstructures.yields.api import FlatForward
from quantlib.cashflows.cap_floored_coupon import CappedFlooredCmsCoupon
from quantlib.cashflows.conundrum_pricer import (
    YieldCurveModel, NumericHaganPricer, AnalyticHaganPricer)
from quantlib.quotes import SimpleQuote

class CmsFairRateTestCase(unittest.TestCase):
    def setUp(self):
        atm_option_tenors = [Period(1, Months), Period(6, Months)] + \
                            [Period(i, Years) for i in [1, 5, 10, 30]]
        atm_swap_tenors = [Period(1, Years), Period(5, Years), Period(10, Years),
                           Period(30, Years)]

        m = np.array([[.1300, .1560, .1390, .1220],
                      [.1440, .1580, .1460, .1260],
                      [.1600, .1590, .1470, .1290],
                      [.1640, .1470, .1370, .1220],
                      [.1400, .1300, .1250, .1100],
                      [.1130, .1090, .1070, .0930]])

        M = Matrix.from_ndarray(m)

        calendar = UnitedStates()
        self.atm_vol = SwaptionVolatilityMatrix(calendar,
                                                Following,
                                                atm_option_tenors,
                                                atm_swap_tenors,
                                                M,
                                                Actual365Fixed())

        reference_date = calendar.adjust(today())

        self.term_structure = FlatForward(reference_date, 0.05, Actual365Fixed())
        self.ibor_index = Euribor6M(self.term_structure)

    def test_fair_rate(self):
        swap_index = SwapIndex("EuriborSwapIsdaFixA",
                               Period(10, Years),
                               self.ibor_index.fixing_days,
                               self.ibor_index.currency,
                               self.ibor_index.fixing_calendar,
                               Period(1, Years),
                               Unadjusted,
                               self.ibor_index.day_counter,
                               self.ibor_index)

        start_date = self.term_structure.reference_date + Period(20, Years)
        payment_date = start_date + Period(1, Years)
        end_date = payment_date
        nominal = 1.0
        gearing = 1.0
        spread = 0.0

        coupon = CappedFlooredCmsCoupon(payment_date, nominal,
                                        start_date, end_date,
                                        swap_index.fixing_days, swap_index,
                                        gearing, spread,
                                        ref_period_start=start_date,
                                        ref_period_end=end_date,
                                        day_counter=self.ibor_index.day_counter)

        for model in YieldCurveModel:
            pricer = NumericHaganPricer(self.atm_vol, model, SimpleQuote(0.))
            coupon.set_pricer(pricer)
            rate_numeric = coupon.rate
            pricer = AnalyticHaganPricer(self.atm_vol, model, SimpleQuote(0.))
            coupon.set_pricer(pricer)
            rate_analytic = coupon.rate
            self.assertAlmostEqual(rate_numeric, rate_analytic, 3)

if __name__ == '__main__':
    unittest.main()
