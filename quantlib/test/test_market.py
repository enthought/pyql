from .unittest_tools import unittest

from quantlib.compounding import Simple
from quantlib.time.api import Date, Actual360
from quantlib.market.market import libor_market, IborMarket


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

    def test_euribor(self):
        """
        Market tests for Euribor futures.

        """
        # Euribor market instance.
        m = IborMarket('Euribor Market', 'EUR:1Y')

        evaluation_date = Date(20, 3, 2014)
        quotes = [
            (u'ERM4', Date(18,  6, 2014), 99.67),
            (u'ERU4', Date(17,  9, 2014), 99.67),
            (u'ERZ4', Date(17, 12, 2014), 99.66),
            (u'ERH5', Date(18,  3, 2015), 99.63),
            (u'ERM5', Date(17,  6, 2015), 99.59),
            (u'ERU5', Date(16,  9, 2015), 99.53),
            (u'ERZ5', Date(16, 12, 2015), 99.46),
            (u'ERH6', Date(16,  3, 2016), 99.38),
        ]

        m.set_quotes(evaluation_date, quotes)
        m.bootstrap_term_structure()

        dt = Date(20, 6, 2014)
        df = m.discount(dt)
        self.assertTrue(df > 0)

    def test_market_internals(self):
        # FIXME: this should be a test case in its own right, closer to
        # YieldTermStructure.

        m = libor_market('USD(NY)')
        eval_date = Date(20, 9, 2004)

        quotes = [('DEP', '1W', 0.0382),
                  ('DEP', '1M', 0.0372),
                  ('DEP', '3M', 0.0363),
                  ('DEP', '6M', 0.0353),
                  ('DEP', '9M', 0.0348),
                  ('DEP', '1Y', 0.0345)]

        m.set_quotes(eval_date, quotes)
        ts = m.bootstrap_term_structure()

        # Compute zero and forward rates.
        zero_rate = ts.zero_rate(Date(1, 1, 2005), Actual360(), Simple)
        forward_rate = ts.forward_rate(Date(1, 1, 2005), Date(30, 1, 2005),
                                       Actual360(), Simple)

        # We don't test for numerical accuracy.
        self.assertGreater(zero_rate.rate, 0)
        self.assertGreater(forward_rate.rate, 0)

        # Check that the linked term structures are consistent with the
        # original term structure.
        discount_ts = m._discount_term_structure
        forecast_ts = m._forecast_term_structure
        self.assertIsNotNone(discount_ts)
        self.assertIsNotNone(forecast_ts)

        for linked_ts in [discount_ts, forecast_ts]:
            rate = linked_ts.zero_rate(
                Date(1, 1, 2005), Actual360(), Simple)
            self.assertEqual(rate.rate, zero_rate.rate)

            rate = linked_ts.forward_rate(
                Date(1, 1, 2005), Date(30, 1, 2005), Actual360(), Simple)
            self.assertEqual(rate.rate, forward_rate.rate)


if __name__ == '__main__':
    unittest.main()
