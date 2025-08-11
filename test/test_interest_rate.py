import unittest

from quantlib.interest_rate import InterestRate

from quantlib.compounding import Continuous, Compounded
from quantlib.time.api import Actual360, Monthly, NoFrequency, Once, Thirty360
from quantlib.time.daycounters.thirty360 import Thirty360

class InterestRateTestCase(unittest.TestCase):

    def setUp(self):

        self.day_counter = Actual360()

    def test_create_interest_rate_frequency_makes_no_sense(self):

        rate = 0.05
        counter = self.day_counter
        compounding = Continuous
        frequency = Monthly

        interest_rate = InterestRate(rate, counter, compounding, frequency)

        self.assertAlmostEqual(interest_rate.rate, rate)
        self.assertEqual(interest_rate.compounding, compounding)

        # Returns NoFrequency when it does not make sense
        self.assertEqual(interest_rate.frequency, NoFrequency)

        # Broken check. DayCoonter != Actual360
        self.assertEqual(interest_rate.day_counter, Actual360())

    def test_create_interest_rate_compounded(self):

        rate = 0.05
        counter = self.day_counter
        compounding = Compounded
        frequency = Monthly

        interest_rate = InterestRate(rate, counter, compounding, frequency)

        self.assertAlmostEqual(interest_rate.rate, rate)
        self.assertEqual(interest_rate.compounding, compounding)
        self.assertEqual(interest_rate.frequency, Monthly)

    def test_create_interest_rate_compounded_error(self):

        rate = 0.05
        counter = self.day_counter
        compounding = Compounded

        for frequency in [Once, NoFrequency]:
            with self.assertRaises(RuntimeError):
                InterestRate(rate, counter, compounding, frequency)

    def test_create_intereste_rate_with_daycounter_convention(self):
        rate = 0.05
        counter = Thirty360(Thirty360.Italian)
        compounding = Compounded
        frequency = Monthly
        interest_rate = InterestRate(rate, counter, compounding, frequency)
        self.assertEqual(interest_rate.day_counter, counter)

    def test_repr(self):

        rate = 0.05
        counter = self.day_counter
        compounding = Compounded
        frequency = Monthly

        interest_rate = InterestRate(rate, counter, compounding, frequency)

        self.assertEqual(
            repr(interest_rate),
            "5.000000 % Actual/360 Monthly compounding"
        )


if __name__ == '__main__':
    unittest.main()
