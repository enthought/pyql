from .unittest_tools import unittest

from quantlib.time.api import Date
from quantlib.market.market import (usd_libor_market, euribor_market)


class MarketTestCase(unittest.TestCase):

    def test_libor_market(self):
        """
        Basic test of Libor market
        Not checking numerical accuracy
        """

        # US libor market, with default conventions:
        # semi-annual fixed vs. 3M Libor
        m = usd_libor_market()

        # add quotes
        eval_date = Date(20, 9, 2004)

        quotes = [('DEP', '1W', 0.0382),
                  ('DEP', '1M', 0.0372),
                  ('DEP', '3M', 0.0363),
                  ('DEP', '6M', 0.0353),
                  ('DEP', '9M', 0.0348),
                  ('DEP', '1Y', 0.0345),
                  ('SWAP', '2Y', 0.037125),
                  ('SWAP', '3Y', 0.0398),
                  ('SWAP', '5Y', 0.0443),
                  ('SWAP', '10Y', 0.05165),
                  ('SWAP', '15Y', 0.055175)]

        m.set_quotes(eval_date, quotes)

        m.bootstrap_term_structure()

        dt = Date(1, 1, 2010)
        df = m.discount(dt)

        print('discount factor for %s (USD Libor): %f' % (dt, df))

        # Euribor market, with default conventions:
        # annual fixed vs. 6M Libor
        m = euribor_market()

        m.set_quotes(eval_date, quotes)

        m.bootstrap_term_structure()

        df = m.discount(dt)

        print('discount factor for %s (Euribor): %f' % (dt, df))
        self.assertTrue(df > 0)

if __name__ == '__main__':
    unittest.main()
