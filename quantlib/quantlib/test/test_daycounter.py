import unittest

from quantlib.time.daycounter import (
    Actual360, DayCounter, SimpleDayCounter
)

from quantlib.time.daycounters.actual_actual import (
    ActualActual, ISDA, ISMA, AFB
)

from quantlib.time.daycounters.thirty360 import (
        Thirty360, EUROBONDBASIS
)
from quantlib.time.date import (
    Date, November, May, February, July, January, December, Period, 
    Months
)

class TestDayCounter(unittest.TestCase):

    def test_create_day_counter(self):

        day_counter = Actual360()
        
        self.assertTrue(day_counter is not None)
        self.assertIsInstance(day_counter, DayCounter)

    def test_daycounter_name(self):

        day_counter = Actual360()
        self.assertEquals('Actual/360', day_counter.name())


class TestActualActual(unittest.TestCase):

    def setUp(self):

        self.from_date = Date(1, November, 2003)
        self.to_date = Date(1, May, 2004)
        self.ref_start = Date(1, November, 2003)
        self.ref_end = Date(1, May, 2004)

    def test_first_example_isda(self):

        day_counter = ActualActual(ISDA)

        self.assertAlmostEqual(
            0.497724380567, 
            day_counter.yearFraction(self.from_date, self.to_date)
        )

    def test_first_example_isma(self):
        day_counter = ActualActual(ISMA)

        self.assertAlmostEqual(
            0.5, 
            day_counter.yearFraction(self.from_date, self.to_date,
                self.ref_start, self.ref_end)
        )

    def test_first_example_afb(self):
        day_counter = ActualActual(AFB)

        self.assertAlmostEqual(
            0.497267759563,
            day_counter.yearFraction(self.from_date, self.to_date)
        )


    def test_short_calculation_first_period_isda(self):
        day_counter = ActualActual(ISDA)
        from_date = Date(1, February, 1999)
        to_date = Date(1, July, 1999)
        
        expected_result = 0.410958904110

        self.assertAlmostEquals(
            expected_result,
            day_counter.yearFraction(from_date, to_date)
        )

    def test_short_calculation_first_period_isma(self):
        day_counter = ActualActual(ISMA)
        from_date = Date(1, February, 1999)
        to_date = Date(1, July, 1999)
        ref_start = Date(1,July,1998)
        ref_end = Date(1,July,1999)
        expected_result = 0.410958904110 

        self.assertAlmostEquals(
            expected_result,
            day_counter.yearFraction(from_date, to_date, ref_start, ref_end)
        )

    def test_short_calculation_first_period_afb(self):
        day_counter = ActualActual(AFB)
        from_date = Date(1, February, 1999)
        to_date = Date(1, July, 1999)
        
        expected_result = 0.410958904110

        self.assertAlmostEquals(
            expected_result,
            day_counter.yearFraction(from_date, to_date)
        )

    def test_short_calculation_second_period_isda(self):
        day_counter = ActualActual(ISDA)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)
        
        expected_result = 1.001377348600

        self.assertAlmostEquals(
            expected_result,
            day_counter.yearFraction(from_date, to_date)
        )

    def test_short_calculation_second_period_isma(self):
        day_counter = ActualActual(ISMA)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)
        ref_start = Date(1, July, 1999)
        ref_end = Date(1, July, 2000)
        

        expected_result = 1.000000000000

        self.assertAlmostEquals(
            expected_result,
            day_counter.yearFraction(from_date, to_date, ref_start, ref_end)
        )


    def test_short_calculation_second_period_afb(self):
        day_counter = ActualActual(AFB)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)
        
        expected_result = 1.000000000000

        self.assertAlmostEquals(
            expected_result,
            day_counter.yearFraction(from_date, to_date)
        )

    def test_simple(self):

        periods = [3, 6, 12]
        expected_times = [0.25, 0.5, 1.0]
        first = Date(1,January,2002)
        last = Date(31,December,2005);

        day_counter = SimpleDayCounter();

        for index, period in enumerate(periods):
            end = first + Period(period,  Months)
            calculated = day_counter.yearFraction(first,end)
            self.assertAlmostEquals(
                expected_times[index], calculated
            )


    def test_thirty360(self):

        day_counter = Thirty360(EUROBONDBASIS)
        from_date = Date(1, July, 1999)
        to_date = Date(1, July, 2000)
        
        expected_result = 1.000000000000

        self.assertAlmostEquals(
            expected_result,
            day_counter.yearFraction(from_date, to_date)
        )

