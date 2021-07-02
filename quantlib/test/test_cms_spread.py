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
from quantlib.experimental.coupons.cms_spread_coupon import (
    CmsSpreadCoupon, CappedFlooredCmsSpreadCoupon)
from quantlib.indexes.api import EuriborSwapIsdaFixA
from quantlib.cashflows.cms_coupon import CmsCoupon
from quantlib.cashflows.linear_tsr_pricer import LinearTsrPricer
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.defines import QL_MAX_REAL, QL_NULL_REAL
from quantlib.math.matrix import Matrix
from quantlib.math.matrixutilities.pseudosqrt import pseudo_sqrt
from quantlib.math.randomnumbers.rngtraits import LowDiscrepancy
from math import sqrt
import numpy as np

class CmsSpreadTestCase(unittest.TestCase):
    def setUp(self):
        self.ref_date = Date(23, 2, 2018)
        Settings().evaluation_date = self.ref_date
        self.yts = FlatForward(self.ref_date, 0.02, Actual365Fixed())
        self.swLn = ConstantSwaptionVolatility.from_reference_date(
            self.ref_date, TARGET(), Following,
            0.2, Actual365Fixed(), VolatilityType.ShiftedLognormal, 0.)
        self.swSLn = ConstantSwaptionVolatility.from_reference_date(
            self.ref_date, TARGET(), Following,
            0.1, Actual365Fixed(), VolatilityType.ShiftedLognormal, 0.01)
        self.swN = ConstantSwaptionVolatility.from_reference_date(
            self.ref_date, TARGET(), Following,
            0.075, Actual365Fixed(), VolatilityType.Normal, 0.01)
        reversion = SimpleQuote(0.01)
        self.cms_pricer_ln = LinearTsrPricer(self.swLn, reversion, self.yts)
        self.cms_pricer_sln = LinearTsrPricer(self.swSLn, reversion, self.yts)
        self.cms_pricer_n = LinearTsrPricer(self.swN, reversion, self.yts)
        self.correlation = SimpleQuote(0.6)
        self.cms_spread_pricer_ln = LognormalCmsSpreadPricer(self.cms_pricer_ln,
                                                             self.correlation, self.yts, 32)
        self.cms_spread_pricer_sln = LognormalCmsSpreadPricer(self.cms_pricer_sln,
                                                              self.correlation, self.yts, 32)
        self.cms_spread_pricer_n = LognormalCmsSpreadPricer(self.cms_pricer_n,
                                                            self.correlation, self.yts, 32)

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

        cpn2a = CmsCoupon(Date(23, 2, 2029), 10000., Date(23, 2, 2028),
                          Date(23, 2, 2029), 2,
                          cms10y, 1., 0., Date(), Date(), Actual360(), False)
        cpn2b = CmsCoupon(Date(23, 2, 2029), 10000., Date(23, 2, 2028),
                          Date(23, 2, 2029), 2,
                          cms2y, 1., 0., Date(), Date(), Actual360(), False)
        plain_cpn = CappedFlooredCmsSpreadCoupon(
            Date(23, 2, 2029), 10000., Date(23, 2, 2028), Date(23, 2, 2029), 2,
            cms10y2y, 1., 0., day_counter=Actual360())
        capped_cpn = CappedFlooredCmsSpreadCoupon(
            Date(23, 2, 2029), 10000., Date(23, 2, 2028), Date(23, 2, 2029), 2,
            cms10y2y, 1., 0., 0.03, day_counter=Actual360())
        floored_cpn = CappedFlooredCmsSpreadCoupon(
            Date(23, 2, 2029), 10000., Date(23, 2, 2028), Date(23, 2, 2029), 2,
            cms10y2y, 1., 0., QL_NULL_REAL, 0.01, day_counter=Actual360())
        collared_cpn = CappedFlooredCmsSpreadCoupon(
            Date(23, 2, 2029), 10000., Date(23, 2, 2028), Date(23, 2, 2029), 2,
            cms10y2y, 1., 0., 0.03, 0.01, day_counter=Actual360())

        cpn2a.set_pricer(self.cms_pricer_ln)
        cpn2b.set_pricer(self.cms_pricer_ln)
        plain_cpn.set_pricer(self.cms_spread_pricer_ln)
        capped_cpn.set_pricer(self.cms_spread_pricer_ln)
        floored_cpn.set_pricer(self.cms_spread_pricer_ln)
        collared_cpn.set_pricer(self.cms_spread_pricer_ln)
        r = self.mc_reference_value(cpn2a, cpn2b, self.swLn, self.correlation.value)
        self.assertAlmostEqual(r.mean(),
                               plain_cpn.rate)
        self.assertAlmostEqual(np.clip(r, None, 0.03).mean(),
                               capped_cpn.rate, 5)
        self.assertAlmostEqual(np.clip(r, 0.01, None).mean(),
                               floored_cpn.rate, 5)
        self.assertAlmostEqual(np.clip(r, 0.01, 0.03).mean(),
                               collared_cpn.rate, 5)

        cpn2a.set_pricer(self.cms_pricer_sln)
        cpn2b.set_pricer(self.cms_pricer_sln)
        plain_cpn.set_pricer(self.cms_spread_pricer_sln)
        capped_cpn.set_pricer(self.cms_spread_pricer_sln)
        floored_cpn.set_pricer(self.cms_spread_pricer_sln)
        collared_cpn.set_pricer(self.cms_spread_pricer_sln)
        r = self.mc_reference_value(cpn2a, cpn2b, self.swSLn, self.correlation.value)
        self.assertAlmostEqual(r.mean(),
                               plain_cpn.rate)
        self.assertAlmostEqual(np.clip(r, None, 0.03).mean(),
                               capped_cpn.rate, 5)
        self.assertAlmostEqual(np.clip(r, 0.01, None).mean(),
                               floored_cpn.rate, 5)
        self.assertAlmostEqual(np.clip(r, 0.01, 0.03).mean(),
                               collared_cpn.rate, 5)


        cpn2a.set_pricer(self.cms_pricer_n)
        cpn2b.set_pricer(self.cms_pricer_n)
        plain_cpn.set_pricer(self.cms_spread_pricer_n)
        capped_cpn.set_pricer(self.cms_spread_pricer_n)
        floored_cpn.set_pricer(self.cms_spread_pricer_n)
        collared_cpn.set_pricer(self.cms_spread_pricer_n)
        r = self.mc_reference_value(cpn2a, cpn2b, self.swN, self.correlation.value)
        self.assertAlmostEqual(r.mean(),
                               plain_cpn.rate)
        self.assertAlmostEqual(np.clip(r, None, 0.03).mean(),
                               capped_cpn.rate, 5)
        self.assertAlmostEqual(np.clip(r, 0.01, None).mean(),
                               floored_cpn.rate, 5)
        self.assertAlmostEqual(np.clip(r, 0.01, 0.03).mean(),
                               collared_cpn.rate, 5)


    @staticmethod
    def mc_reference_value(cpn1, cpn2, vol, correlation):
        samples = 1000000
        Cov = Matrix(2, 2)
        Cov[0,0] = vol.black_variance(cpn1.fixing_date, cpn1.index.tenor,
                                      cpn1.index_fixing)
        Cov[1,1] = vol.black_variance(cpn1.fixing_date, cpn1.index.tenor,
                                      cpn1.index_fixing)
        Cov[0,1] = Cov[1,0] = sqrt(Cov[0,0] * Cov[1,1]) * correlation
        C = pseudo_sqrt(Cov).to_ndarray()
        atm_rate = np.array([cpn1.index_fixing,
                             cpn2.index_fixing])
        adj_rate = np.array([cpn1.adjusted_fixing,
                             cpn2.adjusted_fixing])
        if vol.volatility_type == VolatilityType.ShiftedLognormal:
            vol_shift = np.array([vol.shift(cpn1.fixing_date, cpn1.index.tenor),
                                  vol.shift(cpn2.fixing_date, cpn2.index.tenor),])
            avg = np.log((adj_rate + vol_shift) / (atm_rate + vol_shift)) - \
                  0.5 * np.array([Cov[0,0], Cov[1,1]])
        else:
            avg = adj_rate
        g = LowDiscrepancy(2, 42)
        it = 0
        z = np.empty((samples, 2))
        for i in range(samples):
            z[i] = next(g)
        z = z.dot(C.T) + avg
        if vol.volatility_type == VolatilityType.ShiftedLognormal:
            z = (atm_rate + vol_shift) * np.exp(z) - vol_shift
        return z[:,0] - z[:,1]
        acc = np.clip(z[:,0] - z[:,1], floor, cap)
        return acc.mean()

if __name__ == '__main__':
    unittest.main()
