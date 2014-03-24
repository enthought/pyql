from .unittest_tools import unittest

from quantlib.compounding import Simple
from quantlib.time.api import Date, Actual360
from quantlib.market.market import libor_market


class MarketTestCase(unittest.TestCase):

    def test_libor_market(self):
        """
        Basic test of Libor market
        Not checking numerical accuracy
        """

        # US libor market, with default conventions:
        # semi-annual fixed vs. 3M Libor
        m = libor_market('USD(NY)')

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
        m = libor_market('EUR:>1Y')

        m.set_quotes(eval_date, quotes)

        m.bootstrap_term_structure()

        df = m.discount(dt)

        print('discount factor for %s (Euribor): %f' % (dt, df))
        self.assertTrue(df > 0)

        # TODO/FIXME: expose _term_structure as a public member of the market.
        ts = m._term_structure
        rate0 = ts.zero_rate(Date(1, 1, 2006), Actual360(), Simple)
        rate1 = ts.forward_rate(Date(1, 1, 2008), Date(1, 1, 2010),
                                Actual360(), Simple)

        # We don't test for numerical accuracy.
        self.assertGreater(rate0.rate, 0)
        self.assertGreater(rate1.rate, 0)

    def test_ed(self):
        """
        Curve construction with EuroDollar futures
        Not checking numerical accuracy
        """

        # US libor market, with default conventions:
        # semi-annual fixed vs. 3M Libor
        m = libor_market('USD(LONDON)')

        # add quotes
        eval_date = Date(20, 9, 2004)

        quotes = [
            ('ED', 1, 96.2875),
            ('ED', 2, 96.7875),
            ('ED', 3, 96.9875),
            ('ED', 4, 96.6875),
            ('ED', 5, 96.4875),
            ('ED', 6, 96.3875),
            ('ED', 7, 96.2875),
            ('ED', 8, 96.0875)]

        m.set_quotes(eval_date, quotes)

        m.bootstrap_term_structure()

        dt = Date(1, 1, 2005)
        df = m.discount(dt)

        print('discount factor for %s (USD Libor): %f' % (dt, df))

        self.assertTrue(df > 0)


if __name__ == '__main__':
    unittest.main()
