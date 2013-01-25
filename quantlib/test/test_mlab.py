from datetime import date
import unittest


from quantlib.mlab.option_pricing import heston_pricer, blsprice
import quantlib.reference.names as nm
import quantlib.reference.data_structures as ds


class OptionPricerTestCase(unittest.TestCase):

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

        from quantlib.settings import Settings
        from quantlib.time.api import today
        Settings.instance().evaluation_date = today()
        call_value = blsprice(100.0, 97.0, 0.1, 0.25, 0.5)
        self.assertAlmostEquals(call_value, 12.61, 2)

if __name__ == '__main__':
    unittest.main()
