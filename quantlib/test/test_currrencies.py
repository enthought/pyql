from .unittest_tools import unittest

from quantlib.currency import Currency, USDCurrency

class TestCurrency(unittest.TestCase):

    def test_create_currency(self):
        currency = Currency()
        self.assertEqual('null currency', str(currency))

    def test_from_name(self):
        cu_1 = Currency.from_name('USD')
        cu_2 = USDCurrency()
        self.assertEqual(cu_1.name, cu_2.name)
        self.assertIsInstance(cu_1, USDCurrency)

if __name__ == '__main__':
    unittest.main()

