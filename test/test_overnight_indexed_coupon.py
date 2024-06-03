import unittest
from quantlib.cashflows.api import OvernightIndexedCoupon
from quantlib.time.date import Date, October, November, December, January, March
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import HandleYieldTermStructure, FlatForward
from quantlib.time.api import Actual360
from quantlib.indexes.api import Sofr
from .utilities import flat_rate

class TestOvernightIndexedCoupon(unittest.TestCase):

    def setUp(self):
        self.today = Date(23, November, 2021)
        Settings().evaluation_date = self.today
        self.forecast_curve = HandleYieldTermStructure()
        self.notional = 10_000
        self.sofr = Sofr(self.forecast_curve)

        self.dates = [
            Date(18, October, 2021), Date(19, October, 2021), Date(20, October, 2021),
            Date(21, October, 2021), Date(22, October, 2021), Date(25, October, 2021),
            Date(26, October, 2021), Date(27, October, 2021), Date(28, October, 2021),
            Date(29, October, 2021), Date(1, November, 2021), Date(2, November, 2021),
            Date(3, November, 2021), Date(4, November, 2021), Date(5, November, 2021),
            Date(8, November, 2021), Date(9, November, 2021), Date(10, November, 2021),
            Date(12, November, 2021), Date(15, November, 2021), Date(16, November, 2021),
            Date(17, November, 2021), Date(18, November, 2021), Date(19, November, 2021),
            Date(22, November, 2021)
        ]
        self.past_rates = [
            0.0008, 0.0009, 0.0008,
            0.0010, 0.0012, 0.0011,
            0.0013, 0.0012, 0.0012,
            0.0008, 0.0009, 0.0010,
            0.0011, 0.0014, 0.0013,
            0.0011, 0.0009, 0.0008,
            0.0007, 0.0008, 0.0008,
            0.0007, 0.0009, 0.0010,
            0.0009
        ]
        self.sofr.add_fixings(self.dates, self.past_rates)

    def make_coupon(self, start_date, end_date):
        return OvernightIndexedCoupon(end_date, self.notional, start_date, end_date, self.sofr)

    def test_past_coupon_rate(self):
        """Testing rate for past overnight-indexed coupon"""
        past_coupon = self.make_coupon(Date(18, October, 2021),
                                       Date(18, November, 2021))
        expected_rate = 0.000987136104
        expected_amount = self.notional * expected_rate * 31.0/360
        self.assertAlmostEqual(past_coupon.rate, expected_rate)
        self.assertAlmostEqual(past_coupon.amount, expected_amount)

    def test_current_coupon_rate(self):
        """Testing rate for current overnight-indexed coupon"""
        self.forecast_curve.link_to(flat_rate(0.0010, Actual360()))
        current_coupon = self.make_coupon(Date(10, November, 2021),
                                          Date(10, December, 2021))
        expected_rate = 0.000926701551
        expected_amount = self.notional * expected_rate * 30.0/360
        self.assertAlmostEqual(current_coupon.rate, expected_rate)
        self.assertAlmostEqual(current_coupon.amount, expected_amount)

        self.sofr.add_fixing(Date(23, November, 2021), 0.0007)
        expected_rate = 0.000916700760
        expected_amount = self.notional * expected_rate * 30.0/360
        self.assertAlmostEqual(current_coupon.rate, expected_rate)
        self.assertAlmostEqual(current_coupon.amount, expected_amount)
        self.sofr.clear_fixings()
        self.sofr.add_fixings(self.dates, self.past_rates)

    def test_future_coupon_rate(self):
        """Testing rate for future overnight-indexed coupon"""
        self.forecast_curve.link_to(flat_rate(0.0010, Actual360()))
        future_coupon = self.make_coupon(Date(10, December, 2021),
                                          Date(10, January, 2022))
        expected_rate = 0.001000043057
        expected_amount = self.notional * expected_rate * 31.0/360
        self.assertAlmostEqual(future_coupon.rate, expected_rate)
        self.assertAlmostEqual(future_coupon.amount, expected_amount)


    def test_rate_when_today_is_holiday(self):
        """Testing rate for overnight-indexed coupon when today is a holiday"""
        with Settings() as s:
            s.evaluation_date = Date(20, November, 2021)
            self.forecast_curve.link_to(flat_rate(0.0010, Actual360()))
            coupon = self.make_coupon(Date(10, November, 2021),
                                      Date(10, December, 2021))
            expected_rate = 0.000930035180
            expected_amount = self.notional * expected_rate * 30.0/360
            self.assertAlmostEqual(coupon.rate, expected_rate)
            self.assertAlmostEqual(coupon.amount, expected_amount)

    def test_accrued_amount_in_the_past(self):
        """Testing accrued amount in the past for overnight-indexed coupon"""
        coupon = self.make_coupon(Date(18, October, 2021),
                                  Date(18, January, 2022))

        expected_amount = self.notional * 0.000987136104 * 31.0/360
        self.assertAlmostEqual(coupon.accrued_amount(Date(18, November, 2021)), expected_amount)

    def test_accrued_amount_spanning_today(self):
        """Testing accrued amount spanning today for current overnight-indexed coupon"""
        self.forecast_curve.link_to(flat_rate(0.0010, Actual360()))
        coupon = self.make_coupon(Date(10, November, 2021),
                                  Date(10, January, 2022))
        expected_amount = self.notional * 0.000926701551 * 30.0/360
        self.assertAlmostEqual(coupon.accrued_amount(Date(10, December, 2021)), expected_amount)
        self.sofr.add_fixing(Date(23, November, 2021), 0.0007)
        expected_amount = self.notional * 0.000916700760 * 30.0/360
        self.assertAlmostEqual(coupon.accrued_amount(Date(10, December, 2021)), expected_amount)
        self.sofr.clear_fixings()
        self.sofr.add_fixings(self.dates, self.past_rates)

    def test_accrued_amount_in_the_futures(self):
        """Testing accrued amount in the future for overnight-indexed coupon"""
        self.forecast_curve.link_to(flat_rate(0.0010, Actual360()))
        coupon = self.make_coupon(Date(10, December, 2021),
                                  Date(10, March, 2022))

        accrual_date = Date(10, January, 2022)
        expected_rate = 0.001000043057
        expected_amount = self.notional * expected_rate * 31.0/360
        self.assertAlmostEqual(coupon.accrued_amount(accrual_date), expected_amount)
