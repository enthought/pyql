import numpy as np

from datetime import date, timedelta

import unittest
import quantlib.reference.data_structures as df
import  quantlib.reference.names as nm

class ReferenceTestCase(unittest.TestCase):

    def setUp(self):
        pass

    def test_option_quotes(self):
        x = df.option_quotes_template().reindex(index=range(10))
        x[nm.STRIKE] = range(10)
        x[nm.OPTION_TYPE] = ['C']*10
        x[nm.EXPIRY_DATE] = [date(2000,1,1)]*10
        x[nm.SPOT] = [100]*10
        self.assertTrue(True)


    def test_riskfree_dividend(self):
        x = df.riskfree_dividend_template().reindex(
            index=[date(2000,1,1)+timedelta(days=k) for k in range(10)])
        x[nm.DIVIDEND_YIELD] = np.linspace(.01, .03, 10)
        x[nm.INTEREST_RATE] = np.linspace(.02, .04, 10)
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
