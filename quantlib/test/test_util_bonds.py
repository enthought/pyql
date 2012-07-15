import unittest

from numpy import array
from numpy.testing import assert_almost_equal

from quantlib.time.api import Date, Jan, Jun, Nov, Mar, Oct
from quantlib.util.bonds import bond_price

class BondUtilTestCase(unittest.TestCase):

    def test_bond_price_scalar(self):

        yields = 0.0625
        coupon_rate = 0.0785
        settle = Date(11, Nov, 1992)
        maturity = Date(1, Mar, 2005)
        issue_date = Date(15, Oct, 1992)
        period = 2
        basis = None

        price, accrued_interest = bond_price(yields, coupon_rate, settle, maturity, period, basis)

        expected_price = 113.60
        expected_accrued_interest = 0.59

        assert_almost_equal(expected_price, price)
        assert_almost_equal(expected_accrued_interest, accrued_interest)



    def test_bond_price(self):

        yields = array([0.04, 0.05, 0.06])
        coupon_rate = 0.05
        settle = Date(20, Jan, 1997)
        maturity = Date(15, Jun, 2002)
        period = 2
        basis = 0

        price, accrued_interest = bond_price(yields, coupon_rate, settle, maturity, period, basis)

        expected_price = array([104.8106, 99.9951, 95.4384])
        expected_accrued_interest = array([0.4945, 0.4945, 0.4945])

        assert_almost_equal(expected_price, price)
        assert_almost_equal(expected_accrued_interest, accrued_interest)

if __name__ == '__main__':
    unittest.main()

