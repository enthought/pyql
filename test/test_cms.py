import unittest

from quantlib.time.api import (
    Period, Months, Days, Years, Following, Actual365Fixed,
    UnitedStates, today, Unadjusted)
from quantlib.math.matrix import Matrix
import numpy as np
from quantlib.termstructures.yield_term_structure import HandleYieldTermStructure
from quantlib.termstructures.volatility.swaption.swaption_vol_matrix \
    import SwaptionVolatilityMatrix
from quantlib.indexes.api import EuriborSwapIsdaFixA
from quantlib.instruments.make_cms import MakeCms
from quantlib.termstructures.yields.api import FlatForward
from quantlib.cashflows.coupon_pricer import set_coupon_pricer
from quantlib.cashflows.cap_floored_coupon import CappedFlooredCmsCoupon
from quantlib.cashflows.conundrum_pricer import (
    YieldCurveModel, NumericHaganPricer, AnalyticHaganPricer)
from quantlib.cashflows.linear_tsr_pricer import LinearTsrPricer
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings

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
        Settings().evaluation_date = reference_date
        self.term_structure = HandleYieldTermStructure(
            FlatForward(reference_date, 0.05, Actual365Fixed())
        )
        self.swap_index = EuriborSwapIsdaFixA(Period(10, Years),
                                              forwarding=self.term_structure)

    def test_fair_rate(self):

        start_date = self.term_structure.current_link.reference_date + Period(20, Years)
        payment_date = start_date + Period(1, Years)
        end_date = payment_date
        nominal = 1.0
        gearing = 1.0
        spread = 0.0
        coupon = CappedFlooredCmsCoupon(payment_date, nominal,
                                        start_date, end_date,
                                        self.swap_index.fixing_days,
                                        self.swap_index,
                                        gearing, spread,
                                        ref_period_start=start_date,
                                        ref_period_end=end_date,
                                        day_counter=self.swap_index.day_counter)

        for model in YieldCurveModel:
            pricer = NumericHaganPricer(self.atm_vol, model, SimpleQuote(0.))
            coupon.set_pricer(pricer)
            rate_numeric = coupon.rate
            pricer = AnalyticHaganPricer(self.atm_vol, model, SimpleQuote(0.))
            coupon.set_pricer(pricer)
            rate_analytic = coupon.rate
        pricer = LinearTsrPricer(self.atm_vol, SimpleQuote(0.))
        coupon.set_pricer(pricer)
        rate_lineartsr = coupon.rate
        self.assertAlmostEqual(rate_lineartsr, rate_analytic, 3)

    def test_cms_swap(self):
        swap_lengths = [1, 5, 6, 10]
        spread = 0.
        cms_list = [MakeCms(Period(t, Years),
                            self.swap_index,
                            self.swap_index.ibor_index,
                            spread,
                            Period(10, Days))() for t in swap_lengths]
        for model in YieldCurveModel:
            num_pricer = NumericHaganPricer(self.atm_vol, model, SimpleQuote(0.))
            analytic_pricer = AnalyticHaganPricer(self.atm_vol, model, SimpleQuote(0.))
            if model == YieldCurveModel.NonParallelShifts:
                lineartsr_pricer = LinearTsrPricer(self.atm_vol, SimpleQuote(0.))
            for cms in cms_list:
                set_coupon_pricer(cms[0], num_pricer)
                price_num = cms.npv
                set_coupon_pricer(cms[0], analytic_pricer)
                price_analytic = cms.npv
                self.assertAlmostEqual(price_num, price_analytic, 3)
                if model == YieldCurveModel.NonParallelShifts:
                    set_coupon_pricer(cms[0], lineartsr_pricer)
                    self.assertAlmostEqual(cms.npv, price_analytic, 3)

if __name__ == '__main__':
    unittest.main()
