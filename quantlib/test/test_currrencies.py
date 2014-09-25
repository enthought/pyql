from .unittest_tools import unittest

from quantlib.currency import Currency, USDCurrency

class TestCurrency(unittest.TestCase):

    def test_create_currency(self):
        currency = Currency()
        self.assertEquals('null currency', str(currency))

    def test_from_name(self):
        cu_1 = Currency.from_name('USD')
        cu_2 = USDCurrency()
        self.assertEquals(cu_1.name, cu_2.name)

if __name__ == '__main__':
    unittest.main()

