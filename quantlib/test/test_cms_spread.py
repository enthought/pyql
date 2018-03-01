import unittest

from quantlib.time.api import (
    Date, Period, Years, TARGET, Actual365Fixed, Following, Actual360)
from quantlib.indexes.api import EuriborSwapIsdaFixA
from quantlib.termstructures.yields.api import FlatForward
from quantlib.termstructures.volatility.api import (
        ConstantSwaptionVolatility, VolatilityType)
from quantlib.experimental.coupons.lognormal_cmsspread_pricer import \
        LognormalCmsSpreadPricer
from quantlib.experimental.coupons.swap_spread_index import SwapSpreadIndex
from quantlib.experimental.coupons.cms_spread_coupon import CmsSpreadCoupon
from quantlib.indexes.api import EuriborSwapIsdaFixA
from quantlib.cashflows.cms_coupon import CmsCoupon
from quantlib.cashflows.linear_tsr_pricer import LinearTsrPricer
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings

class CmsSpreadTestCase(unittest.TestCase):
    def setUp(self):
        self.ref_date = Date(23, 2, 2018)
        Settings().evaluation_date = self.ref_date
        self.yts = FlatForward(self.ref_date, 0.02, Actual365Fixed())
        swLn = ConstantSwaptionVolatility.from_reference_date(
                self.ref_date, TARGET(), Following,
                0.2, Actual365Fixed(), VolatilityType.ShiftedLognormal, 0.)
        swSLn = ConstantSwaptionVolatility.from_reference_date(
                self.ref_date, TARGET(), Following,
                0.1, Actual365Fixed(), VolatilityType.ShiftedLognormal, 0.01)
        swN = ConstantSwaptionVolatility.from_reference_date(
                self.ref_date, TARGET(), Following,
                0.075, Actual365Fixed(), VolatilityType.Normal, 0.01)
        reversion = SimpleQuote(0.01)
        self.cms_pricer_ln = LinearTsrPricer(swLn, reversion, self.yts)
        self.cms_pricer_sln = LinearTsrPricer(swSLn, reversion, self.yts)
        self.cms_pricer_n = LinearTsrPricer(swN, reversion, self.yts)
        correlation = SimpleQuote(0.6)
        self.cms_spread_pricer_ln = LognormalCmsSpreadPricer(self.cms_pricer_ln,
                                                             correlation, self.yts, 32)
        self.cms_spread_pricer_sln = LognormalCmsSpreadPricer(self.cms_pricer_sln,
                                                              correlation, self.yts, 32)
        self.cms_spread_pricer_n = LognormalCmsSpreadPricer(self.cms_pricer_n,
                                                            correlation, self.yts, 32)

    def test_coupon_pricing(self):
        tol = 1e-6
        cms10y = EuriborSwapIsdaFixA(Period(10, Years), self.yts)
        cms2y = EuriborSwapIsdaFixA(Period(2, Years), self.yts)
        cms10y2y = SwapSpreadIndex("cms10y2y", cms10y, cms2y)
        value_date = cms10y2y.value_date(self.ref_date)
        pay_date = value_date + Period(1, Years)
        cpn1a = CmsCoupon(pay_date, 10000., value_date, pay_date,
                cms10y.fixing_days, cms10y, 1., 0., Date(), Date(),
                Actual360(), False)
        cpn1b = CmsCoupon(pay_date, 10000., value_date, pay_date,
                cms2y.fixing_days, cms2y, 1., 0., Date(), Date(),
                Actual360(), False)
        cpn1 = CmsSpreadCoupon(pay_date, 10000., value_date, pay_date,
                cms10y2y.fixing_days, cms10y2y, 1., 0., Date(), Date(),
                Actual360(), False)
        cpn1a.set_pricer(self.cms_pricer_ln)
        cpn1b.set_pricer(self.cms_pricer_ln)
        cpn1.set_pricer(self.cms_spread_pricer_ln)
        self.assertEqual(cpn1.rate , cpn1a.rate - cpn1b.rate)
        cms10y.add_fixing(self.ref_date, 0.05)
        self.assertEqual(cpn1.rate , cpn1a.rate - cpn1b.rate)
        cms2y.add_fixing(self.ref_date, 0.03)
        self.assertEqual(cpn1.rate , cpn1a.rate - cpn1b.rate)

if __name__ == '__main__':
    unittest.main()
