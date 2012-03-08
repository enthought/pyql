import unittest

from quantlib.currency import Currency

class TestCurrency(unittest.TestCase):

    def test_create_currency(self):
        currency = Currency()
        self.assertEquals('null currency', str(currency))

