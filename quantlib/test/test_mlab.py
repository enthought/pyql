from datetime import date
import os
import unittest


import pandas
from pandas import DataFrame
from quantlib.mlab.option_pricing import heston_pricer, options_to_rates

class OptionPricerTestCase(unittest.TestCase):

    def test_option_to_rate(self):

        option_data_frame = pandas.core.common.load(
            os.path.join('quantlib', 'test','data','df_SPX_24jan2011.pkl')
        )

        rates = options_to_rates(option_data_frame)

        dRate = rates['dRate'][-1]
        iRate = rates['iRate'][-1]

        self.assertAlmostEqual(dRate, 0.02290,4)
        self.assertAlmostEqual(iRate, 0.01305,4)

    def test_heston_pricer(self):

        trade_date = date(2011,1,24)
        spot = 1290.58

        # option definition
        options = DataFrame(
            {
                'Type': ['C', 'P'],
                'Strike': [1290, 1290],
                'dtExpiry': [date(2015, 1, 1), date(2015, 1, 1)],
                'Spot': [spot] * 2
            }
        )

        # interest rate and dividend yield
        rates = DataFrame(
            {
                'dRate': [.021, .023, .024],
                'iRate': [.010, .015, .019]
            },
            index=[date(2011, 3, 16), date(2013, 3, 16), date(2015, 3, 16)]
        )

        # heston model
        heston_params = dict(
            v0=0.051965, kappa=0.977314, theta=0.102573, sigma= 0.987796,
            rho=-0.747033
        )

        results = heston_pricer(trade_date, options,
                                heston_params, rates, spot=1290.58)

        price_call = results['Price'][0]
        price_put = results['Price'][1]

        self.assertAlmostEqual(price_call, 194.6, 1)
        self.assertAlmostEqual(price_put, 218.9, 1)

if __name__ == '__main__':
    unittest.main()
