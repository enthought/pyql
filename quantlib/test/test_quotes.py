from .unittest_tools import unittest

from quantlib.quotes import SimpleQuote


class SimpleQuoteTestCase(unittest.TestCase):

    def test_round_trip(self):

        value = 72.03
        quote = SimpleQuote(value)
        self.assertLess(abs(value - quote.value), 1e-12)
