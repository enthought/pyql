import unittest

from quantlib.time.date import (
    Date, Period, Jan, Dec, Weeks, Sep, Months, Nov
)
from quantlib.time.calendar import Following, Preceding
from quantlib.time.calendars.united_kingdom import UnitedKingdom
from quantlib.time.schedule import Schedule, Twentieth, Forward, Backward

class ScheduleTestCase(unittest.TestCase):

    def test_create_schedule(self):

        from_date = Date(1, Jan, 2011)
        to_date = Date(31, Dec, 2011)
        tenor = Period(3, Weeks)
        calendar = UnitedKingdom()
        convention = Following
        termination_convention = Following
        rule = Forward

        schedule = Schedule(from_date, to_date, tenor, calendar, convention,
                termination_convention, rule)

        for date in schedule.dates():
            print date

        self.assert_(schedule is not None)

class ScheduleMethodTestCase(unittest.TestCase):

    def setUp(self):
        self.from_date = Date(1, Jan, 2011)
        self.to_date = Date(31, Dec, 2011)
        self.tenor = Period(4, Weeks)
        self.calendar = UnitedKingdom()
        self.convention = Following
        self.termination_convention = Preceding
        self.rule = Twentieth

        self.schedule = Schedule(
            self.from_date, self.to_date, self.tenor, self.calendar, 
            self.convention, self.termination_convention, self.rule
        )


        for date in self.schedule.dates():
            print date

    def test_size(self):
        
        self.assertEquals(15, self.schedule.size())

    def test_dates(self):
        
        expected_dates_length = self.schedule.size()
        dates = list(self.schedule.dates())

        self.assertEquals(expected_dates_length, len(dates))

        for date in dates:
            print date


    def test_at(self):
        
        expected_date = self.calendar.adjust(self.from_date, Following)
        self.assertTrue(expected_date == self.schedule.at(0))

        next_date = self.calendar.adjust(
            self.from_date + Period(4, Weeks), Following
        )
        expected_date = Date(20, next_date.month, next_date.year)
        print expected_date, self.schedule.at(1)
        
        self.assertTrue(expected_date == self.schedule.at(1))
        
    def test_previous_next_reference_date(self):
        from_date = Date(3, Sep, 2011)
        to_date = Date(15, Dec, 2011)
        tenor = Period(1, Months)
        calendar = UnitedKingdom()
        convention = Following
        termination_convention = Following
        rule = Forward

        fwd_schedule = Schedule(from_date, to_date, tenor, calendar, convention,
                termination_convention, rule)

        expected_date = Date(5, Sep, 2011) 
        print expected_date, fwd_schedule.next_date(from_date)
        self.assert_(expected_date == fwd_schedule.next_date(from_date))

        rule = Backward

        bwd_schedule = Schedule(from_date, to_date, tenor, calendar, convention,
                termination_convention, rule)

        expected_date = Date(15, Nov, 2011) 
        self.assert_(expected_date == bwd_schedule.previous_date(to_date))




if __name__ == '__main__':
    unittest.main()
