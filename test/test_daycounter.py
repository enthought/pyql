import unittest

from quantlib.time.daycounter import DayCounter

from quantlib.time.daycounters.simple import (
    Actual360, SimpleDayCounter
)

from quantlib.time.daycounters.actual_actual import ActualActual

from quantlib.time.daycounters.thirty360 import (
        Thirty360, Convention
)
from quantlib.time.date import (
    Date, November, May, February, July, January, Period,
    Months
)

class TestDayCounter(unittest.TestCase):

    def test_create_day_counter(self):

        day_counter = Actual360()

        self.assertTrue(day_counter is not None)
        self.assertIsInstance(day_counter, DayCounter)

    def test_daycounter_name(self):

        day_counter = Actual360()
        self.assertEqual('Actual/360', day_counter.name)
        self.assertEqual('Actual/360', str(day_counter))

    def test_empty_daycounter(self):
        day_counter = DayCounter()
        with self.assertRaisesRegex(RuntimeError, r"no (day counter )?implementation provided"):
            day_counter.name

class TestDayCounterFromName(unittest.TestCase):

    def test_create_simple_daycounter_from_name(self):

        type_vs_name = {
            'Actual360' : 'Actual/360',
            'Actual/360' : 'Actual/360',
            'Actual/360 (inc)': 'Actual/360 (inc)',
            'Actual365Fixed' : 'Actual/365 (Fixed)',
            'Actual/365' : 'Actual/365 (Fixed)',
            'OneDayCounter' : '1/1',
            '1/1' : '1/1',
        }

        for counter_type, expected_name in type_vs_name.items():

            cnt = DayCounter.from_name(counter_type)
            self.assertEqual(cnt.name, expected_name)

    def test_create_daycounter_with_convention_from_name(self):

        type_vs_name = {
            'Actual/Actual (Bond)' : 'Actual/Actual (ISMA)',
            'Actual/Actual (ISMA)' : 'Actual/Actual (ISMA)',
            'Actual/Actual (ISDA)' : 'Actual/Actual (ISDA)',
            'Actual/Actual (Historical)' : 'Actual/Actual (ISDA)',
            'Actual/Actual (Actual365)' : 'Actual/Actual (ISDA)',
            'Actual/Actual (AFB)' : 'Actual/Actual (AFB)',
            'Actual/Actual (Euro)' : 'Actual/Actual (AFB)',
        }

        for counter_type, expected_name in type_vs_name.items():

            cnt = DayCounter.from_name(counter_type)
            self.assertEqual(cnt.name, expected_name)



class TestActualActual(unittest.TestCase):

    def setUp(self):

        self.from_date = Date(1, November, 2003)
        self.to_date = Date(1, May, 2004)
        self.ref_start = Date(1, November, 2003)
        self.ref_end = Date(1, May, 2004)

    def test_first_example_isda(self):

        day_counter = ActualActual(ActualActual.ISDA)

        self.assertAlmostEqual(
            0.497724380567,
            day_counter.year_fraction(self.from_date, self.to_date)
        )

    def test_first_example_isma(self):
        day_counter = ActualActual(ActualActual.ISMA)

        self.assertAlmostEqual(
            0.5,
            day_counter.year_fraction(self.from_date, self.to_date,
                self.ref_start, self.ref_end)
        )

    def test_first_example_afb(self):
        day_counter = ActualActual(ActualActual.AFB)

        self.assertAlmostEqual(
            0.497267759563,
            day_counter.year_fraction(self.from_date, self.to_date)
        )


    def test_short_calculation_first_period_isda(self):
        day_counter = ActualActual(ActualActual.ISDA)
        from_date = Date(1, February, 1999)
        to_date = Date(1, July, 1999)

        expected_result = 0.410958904110

        self.assertAlmostEqual(
            expected_result,
            day_counter.year_fraction(from_date, to_date)
        )

    def test_short_calculation_first_period_isma(self):
        day_counter = ActualActual(ActualActual.ISMA)
        from_date = Date(1, February, 1999)
        to_date = Date(1, July, 1999)
        ref_start = Date(1,July,1998)
        ref_end = Date(1,July,1999)
        expected_result = 0.410958904110

        self.assertAlmostEqual(
            expected_result,
            day_counter.year_fraction(from_date, to_date, ref_start, ref_end)
        )

    def test_short_calculation_first_period_afb(self):
        day_counter = ActualActual(ActualActual.AFB)
        from_date = Date(1, February, 1999)
        to_date = Date(1, July, 1999)

        expected_result = 0.410958904110

        self.assertAlmostEqual(
            expected_result,
            day_counter.year_fraction(from_date, to_date)
        )

    def test_short_calculation_second_period_isda(self):
        day_counter = ActualActual(ActualActual.ISDA)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)

        expected_result = 1.001377348600

        self.assertAlmostEqual(
            expected_result,
            day_counter.year_fraction(from_date, to_date)
        )

    def test_short_calculation_second_period_isma(self):
        day_counter = ActualActual(ActualActual.ISMA)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)
        ref_start = Date(1, July, 1999)
        ref_end = Date(1, July, 2000)


        expected_result = 1.000000000000

        self.assertAlmostEqual(
            expected_result,
            day_counter.year_fraction(from_date, to_date, ref_start, ref_end)
        )


    def test_short_calculation_second_period_afb(self):
        day_counter = ActualActual(ActualActual.AFB)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)

        expected_result = 1.000000000000

        self.assertAlmostEqual(
            expected_result,
            day_counter.year_fraction(from_date, to_date)
        )

    def test_simple(self):

        periods = [3, 6, 12]
        expected_times = [0.25, 0.5, 1.0]
        first = Date(1,January,2002)

        day_counter = SimpleDayCounter();

        for index, period in enumerate(periods):
            end = first + Period(period,  Months)
            calculated = day_counter.year_fraction(first,end)
            self.assertAlmostEqual(
                expected_times[index], calculated
            )


    def test_thirty360(self):

        day_counter = Thirty360(Thirty360.EurobondBasis)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)

        expected_result = 1.000000000000

        self.assertAlmostEqual(
            expected_result,
            day_counter.year_fraction(from_date, to_date)
        )


    def test_equality_method(self):

        day_counter = Thirty360(Thirty360.EurobondBasis)

        a = Thirty360()
        self.assertNotEqual(day_counter, a)
        self.assertNotEqual(day_counter, Thirty360())
        self.assertEqual(day_counter, Thirty360(Thirty360.EurobondBasis))

    def test_thirty360_from_name(self):
        for c in Convention:
            dc = Thirty360(c)
            try:
                dc2 = DayCounter.from_name(dc.name)
            except ValueError:
                pass
            else:
                self.assertEqual(dc, dc2)

if __name__ == '__main__':
    unittest.main()
