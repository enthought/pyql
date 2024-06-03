import unittest
from quantlib.time.api import TARGET, Date, Actual360, Days, Months, NoFrequency
from quantlib.termstructures.yields.api import HandleYieldTermStructure, ZeroCurve, PiecewiseZeroSpreadedTermStructure
from quantlib.compounding import Continuous
from quantlib.settings import Settings
from quantlib.quotes import SimpleQuote
from quantlib.interest_rate import InterestRate

class TestPiecewiseZeroSpreadedTermStructure(unittest.TestCase):

    def setUp(self):
        self.calendar = TARGET()
        self.today = Date(9, 6, 2009)
        settlement_date = self.calendar.advance(self.today, 2, Days)
        Settings().evaluation_date = self.today
        rates = [0.035, 0.035, 0.033, 0.034, 0.034, 0.036, 0.037, 0.039, 0.04]
        ts = [13, 41, 75, 165, 256, 345, 524, 703]
        dates = [settlement_date] + [self.calendar.advance(self.today, d, Days) for d in ts]
        self.day_counter = Actual360()
        self.term_structure = ZeroCurve(dates, rates, self.day_counter)
        self.spreads = [SimpleQuote(0.02), SimpleQuote(0.03)]
        self.spread_dates = [self.calendar.advance(self.today, 8, Months),
                             self.calendar.advance(self.today, 15, Months)]

        self.spreaded_term_structure = PiecewiseZeroSpreadedTermStructure(
            HandleYieldTermStructure(self.term_structure),
            self.spreads,
            self.spread_dates)
        self.spreaded_term_structure.extrapolation = True

    def test_flat_interpolation_left(self):
        interpolation_date = self.calendar.advance(self.today, 6, Months)
        t = self.day_counter.year_fraction(self.today, interpolation_date)
        interpolated_zero_rate = (self.spreaded_term_structure.
                                  zero_rate(t, compounding=Continuous).rate)

        expected_rate = self.term_structure.zero_rate(t, compounding=Continuous).rate + \
            self.spreads[0].value
        self.assertAlmostEqual(interpolated_zero_rate, expected_rate)

    def test_flat_interpolation_right(self):
        interpolation_date = self.calendar.advance(self.today, 20, Months)
        t = self.day_counter.year_fraction(self.today, interpolation_date)
        interpolated_zero_rate = (self.spreaded_term_structure.
                                  zero_rate(t, compounding=Continuous).rate)
        expected_rate = self.term_structure.zero_rate(t, compounding=Continuous).rate + \
            self.spreads[1].value
        self.assertAlmostEqual(interpolated_zero_rate, expected_rate)

    def test_linear_interpolation(self):
        interpolation_date = self.calendar.advance(self.today, 12, Months)
        t = self.term_structure.time_from_reference(interpolation_date)
        t1 = self.term_structure.time_from_reference(self.spread_dates[0])
        t2 = self.term_structure.time_from_reference(self.spread_dates[1])
        interpolated_zero_rate = (self.spreaded_term_structure.
                                  zero_rate(t, compounding=Continuous).rate)

        zero_rate = (self.term_structure.
                     zero_rate(t, compounding=Continuous, frequency=NoFrequency))
        expected_rate = zero_rate.rate + \
            (t - t1) / (t2 - t1 ) * self.spreads[1].value + \
            (t2 - t) / (t2 - t1) * self.spreads[0].value
        spreaded_rate = InterestRate(expected_rate,
                                     zero_rate.day_counter,
                                     zero_rate.compounding,
                                     zero_rate.frequency)

        self.assertAlmostEqual(interpolated_zero_rate,
                               spreaded_rate.equivalent_rate(Continuous, NoFrequency, t).rate)


if __name__ == "__main__":
    unittest.main()
