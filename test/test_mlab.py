import unittest

from datetime import date
from quantlib.mlab.option_pricing import heston_pricer, blsprice, blsimpv
from quantlib.mlab.fixed_income import bndprice, cfamounts
from quantlib.mlab.term_structure import zbt_libor_yield
from quantlib.instruments.option import OptionType

from quantlib.util.rates import make_rate_helper, zero_rate
import quantlib.reference.names as nm
import quantlib.reference.data_structures as ds

from quantlib.termstructures.yields.api import (
    PiecewiseYieldCurve, BootstrapTrait )
from quantlib.math.interpolation import LogLinear
from quantlib.time.api import ActualActual, ISDA
from quantlib.util.converter import pydate_to_qldate


class MLabTestCase(unittest.TestCase):

    def test_heston_pricer(self):

        trade_date = date(2011, 1, 24)
        spot = 1290.58

        # option definition
        options = ds.option_quotes_template().reindex(index=range(2))
        options[nm.OPTION_TYPE] = ['C', 'P']
        options[nm.STRIKE] = [1290, 1290]
        options[nm.EXPIRY_DATE] = [date(2015, 1, 1), date(2015, 1, 1)]
        options[nm.SPOT] = [spot] * 2

        # interest rate and dividend yield
        rates = ds.riskfree_dividend_template().reindex(
            index=[date(2011, 3, 16), date(2013, 3, 16), date(2015, 3, 16)])
        rates[nm.DIVIDEND_YIELD] = [.021, .023, .024]
        rates[nm.INTEREST_RATE] = [.010, .015, .019]

        # heston model
        heston_params = dict(v0=0.051965,
            kappa=0.977314, theta=0.102573,
            sigma=0.987796, rho=-0.747033
        )

        results = heston_pricer(trade_date, options,
                                heston_params, rates, spot=1290.58)

        price_call = results[nm.PRICE][0]
        price_put = results[nm.PRICE][1]

        self.assertAlmostEqual(price_call, 194.6, 1)
        self.assertAlmostEqual(price_put, 218.9, 1)

    def test_blsprice(self):
        """
        from matlab documentation of blsprice
        """
        p = blsprice(spot=585, strike=600, risk_free_rate=.05,
                     time=1 / 4., volatility=.25,
                     option_type=(OptionType.Call, OptionType.Put),
                     dividend=0.045)

        self.assertAlmostEqual(p[0], 22.6716, 3)
        self.assertAlmostEqual(p[1], 36.7626, 3)

        v = blsimpv(p, spot=585, strike=600, risk_free_rate=.05,
                     time=1 / 4.,
                     option_type=(OptionType.Call, OptionType.Put),
                     dividend=0.045)

        self.assertAlmostEqual(v[0], .25, 3)
        self.assertAlmostEqual(v[1], .25, 3)

    def test_yield(self):

        rates_data = [('Libor1M',.01),
                  ('Libor3M', .015),
                  ('Libor6M', .017),
                  ('Swap1Y', .02),
                  ('Swap2Y', .03),
                  ('Swap3Y', .04),
                  ('Swap5Y', .05),
                  ('Swap7Y', .06),
                  ('Swap10Y', .07),
                  ('Swap20Y', .08)]

        settlement_date = pydate_to_qldate('01-Dec-2013')
        rate_helpers = []
        for label, rate in rates_data:
            h = make_rate_helper(label, rate, settlement_date)
            rate_helpers.append(h)

            ts_day_counter = ActualActual(ISDA)
            tolerance = 1.0e-15

        ts = PiecewiseYieldCurve[BootstrapTrait.Discount, LogLinear].from_reference_date(
            settlement_date, rate_helpers,
            ts_day_counter, accuracy=tolerance
        )

        zc = zero_rate(ts, (200, 300), settlement_date)
        # not a real test - just verify execution
        self.assertAlmostEqual(zc[1][0], 0.0189, 2)

    def test_bndprice(self):
        """
        Test from Matlab bndprice help
        ac is matched exactly
        price accurate to 10^-3
        """

        Yield = [0.04, 0.05, 0.06]
        CouponRate = 0.05
        Maturity = '15-Jun-2002'

        (price, ac) = bndprice(bond_yield=Yield, coupon_rate=CouponRate,
                           pricing_date='18-Jan-1997',
                           maturity_date=Maturity,
                           period='Semiannual',
                           basis='Actual/Actual (Bond)',
                           compounding_frequency='Semiannual')

        # Matlab values
        ml_price = [104.8106, 99.9951, 95.4384]
        ml_ac = [0.4945, ] * 3
        for i, p in enumerate(price):
            self.assertAlmostEqual(p, ml_price[i], 2)

        for i, a in enumerate(ac):
            self.assertAlmostEqual(a, ml_ac[i], 3)

    def test_cfamounts(self):
        """
        Test from Matlab cfamounts help
        """

        CouponRate = 0.05
        Maturity = '15-Jun-1995'

        res = cfamounts(coupon_rate=CouponRate,
                           pricing_date='29-oct-1993',
                           maturity_date=Maturity,
                           period='Semiannual',
                           basis='Actual/Actual (Bond)')

        for cf, dt in zip(*res):
            print('%s %7.2f' % (dt, cf))

        dt = res[1]
        cf = res[0]
        pydate = date(1993, 6, 15)

        self.assertEqual(cf[6], 100.0)
        self.assertEqual(dt[1], pydate)

    def test_greeks(self):
        """
        From Matlab help for blsdelta, blsgamma
        """
        c, p = blsprice(spot=50, strike=50, risk_free_rate=.1,
                  time=0.25, volatility=.3,
                  option_type=(OptionType.Call, OptionType.Put), calc='delta')

        matlab_c = 0.5955
        matlab_p = -0.4045

        self.assertAlmostEqual(c, matlab_c, 3)
        self.assertAlmostEqual(p, matlab_p, 3)

        g = blsprice(spot=50, strike=50, risk_free_rate=.12,
                     time=0.25, volatility=.3,
                     option_type=OptionType.Call, calc='gamma')

        matlab_g = 0.0512
        self.assertAlmostEqual(g, matlab_g, 3)

    def test_zero_rate(self):
        """
        Not a real test - just verifies that it runs
        """

        instruments = ['Libor1M',
                   'Libor3M',
                   'Libor6M',
                   'Swap1Y',
                   'Swap2Y',
                   'Swap3Y',
                   'Swap5Y',
                   'Swap7Y',
                   'Swap10Y',
                   'Swap20Y',
                   'Swap30Y']
        yields = [float(x+1)/100 for x in range(len(instruments))]

        pricing_date = '01-dec-2013'
        dt, rates = zbt_libor_yield(instruments, yields, pricing_date,
                    compounding_freq='Continuous',
                    maturity_dates=None)

        self.assertAlmostEqual(rates[0], .01, 3)

if __name__ == '__main__':
    unittest.main()
