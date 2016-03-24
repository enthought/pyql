from .unittest_tools import unittest

from quantlib.time.calendar import (
    Following, ModifiedFollowing, ModifiedPreceding, Preceding, TARGET,
    holiday_list
)
from quantlib.time.calendars.united_kingdom import UnitedKingdom, EXCHANGE
from quantlib.time.calendars.united_states import UnitedStates, NYSE
from quantlib.time.calendars.canada import Canada, TSX
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.calendars.germany import (
    Germany, FRANKFURT_STOCK_EXCHANGE
)
from quantlib.time.calendars.weekends_only import WeekendsOnly
from quantlib.time.date import (
    Date, May, March, June, Jan, August, Months,November, Period, Days,
    Apr, Jul, Sep, Oct, Dec, Nov)
from quantlib.time.calendars.jointcalendar import (
    JointCalendar, JOINHOLIDAYS, JOINBUSINESSDAYS
)
from quantlib.util.version import QUANTLIB_VERSION

# QuantLib 1.4 added one extra holiday to the 2011 UK calendar (29 April 2011,
# the royal wedding), bringing the total to 9 holidays.
major, minor = QUANTLIB_VERSION[:2]
if major >= 1 and minor >= 4:
    UK_HOLIDAYS_2011 = 9
else:
    UK_HOLIDAYS_2011 = 8


class TestQuantLibCalendar(unittest.TestCase):

    def test_calendar_creation(self):

        calendar = TARGET()
        self.assertEqual('TARGET',  calendar.name)

        ukcalendar = UnitedKingdom()
        self.assertEqual('UK settlement',  ukcalendar.name)

        lse_cal = UnitedKingdom(market=EXCHANGE)
        self.assertEqual('London stock exchange',  lse_cal.name)

        null_calendar = NullCalendar()
        self.assertEqual('Null', null_calendar.name)

    def test_christmas_is_holiday(self):

        calendar = TARGET()

        date = Date(24,12, 2011)

        self.assertTrue(calendar.is_holiday(date))

    def test_is_business_day(self):

        ukcal = UnitedKingdom()

        bank_holiday_date = Date(3, May, 2010) #Early May Bank Holiday
        business_day = Date(28, March, 2011)

        self.assertFalse(ukcal.is_business_day(bank_holiday_date))
        self.assertTrue(ukcal.is_business_day(business_day))

    def test_joint(self):

        ukcal = UnitedKingdom()
        uscal = UnitedStates()

        bank_holiday_date = Date(3, May, 2010) #Early May Bank Holiday
        thanksgiving_holiday_date = Date(22, Nov, 2012)

        jtcal = JointCalendar(ukcal, uscal, JOINHOLIDAYS)

        self.assertFalse(jtcal.is_business_day(bank_holiday_date))
        self.assertFalse(jtcal.is_business_day(thanksgiving_holiday_date))

        jtcal = JointCalendar(ukcal, uscal, JOINBUSINESSDAYS)

        self.assertTrue(jtcal.is_business_day(bank_holiday_date))
        self.assertTrue(jtcal.is_business_day(thanksgiving_holiday_date))

    def test_business_days_between_dates(self):

        ukcal = UnitedKingdom()

        date1 = Date(30, May, 2011)

        # 30st of May is Spring Bank Holiday
        date2 = Date(3, June, 2011)

        day_count = ukcal.business_days_between(date1, date2, include_last=True)

        self.assertEqual(4, day_count)

    def test_holiday_list_acces_and_modification(self):

        ukcal = UnitedKingdom()

        holidays = list(
            holiday_list(ukcal, Date(1, Jan, 2011), Date(31, 12,2011) )
        )
        self.assertEqual(UK_HOLIDAYS_2011, len(holidays))

        new_holiday_date = Date(23, August, 2011)

        ukcal.add_holiday(new_holiday_date)

        holidays = list(
            holiday_list(ukcal, Date(1, Jan, 2011), Date(31, 12,2011) )
        )
        self.assertEqual(UK_HOLIDAYS_2011 + 1, len(holidays))

        ukcal.remove_holiday(new_holiday_date)

        holidays = list(
            holiday_list(ukcal, Date(1, Jan, 2011), Date(31, 12,2011) )
        )
        self.assertEqual(UK_HOLIDAYS_2011, len(holidays))

    def test_adjust_business_day(self):

        ukcal = UnitedKingdom()

        bank_holiday_date = Date(3, May, 2010) #Early May Bank Holiday

        adjusted_date = ukcal.adjust(bank_holiday_date)
        following_date = bank_holiday_date + 1
        self.assertTrue(following_date == adjusted_date)

        adjusted_date = ukcal.adjust(bank_holiday_date, convention=Preceding)
        following_date = bank_holiday_date - 3 # bank holiday is a Monday
        self.assertTrue(following_date == adjusted_date)

        adjusted_date = ukcal.adjust(bank_holiday_date,
                convention=ModifiedPreceding)
        following_date = bank_holiday_date + 1 # Preceding is on a different
                                               # month
        self.assertTrue(following_date == adjusted_date)

    def test_calendar_date_advance(self):
        ukcal = UnitedKingdom()

        bank_holiday_date = Date(3, May, 2010) #Early May Bank Holiday

        advanced_date = ukcal.advance(bank_holiday_date, step=6, units=Months)
        expected_date = Date(3, November, 2010)
        self.assertTrue(expected_date == advanced_date)

        period_10days = Period(10, Days)
        advanced_date = ukcal.advance(bank_holiday_date, period=period_10days)
        expected_date = Date(17, May, 2010)
        self.assertTrue(expected_date == advanced_date)

    def test_united_states_calendar(self):

        uscal = UnitedStates()
        holiday_date = Date(4, Jul, 2010)

        self.assertTrue(uscal.is_holiday(holiday_date))

        uscal = UnitedStates(market=NYSE)
        holiday_date = Date(5, Sep, 2011) # Labor day

        self.assertTrue(uscal.is_holiday(holiday_date))

    def test_canada_calendar(self):

        cacal = Canada()
        holiday_date = Date(1, Jul, 2015)

        self.assertTrue(cacal.is_holiday(holiday_date))

        cacal = Canada(market=TSX)
        holiday_date = Date(3, August, 2015)

        self.assertTrue(cacal.is_holiday(holiday_date))

    def test_german_calendar(self):

        frankfcal   = Germany(FRANKFURT_STOCK_EXCHANGE);
        first_date  = Date(31,Oct,2009)
        second_date = Date(1,Jan ,2010);

        Dec_30_2009 = Date(30, Dec, 2009)
        Jan_4_2010 = Date(4, Jan, 2010)

        self.assertEqual(
            Dec_30_2009, frankfcal.adjust(second_date , Preceding)
        )
        self.assertEqual(
            Jan_4_2010,
            frankfcal.adjust(second_date , ModifiedPreceding)
        )

        mat = Period(2,Months)

        self.assertEqual(
            Jan_4_2010,
            frankfcal.advance(
                first_date, period=mat, convention=Following,
                end_of_month=False
            )
        )
        self.assertEqual(
            Dec_30_2009,
            frankfcal.advance(
                first_date, period=mat, convention=ModifiedFollowing,
                end_of_month=False
            )
        )
        self.assertEqual(
            41,
            frankfcal.business_days_between(
                first_date, second_date, False, False
            )
        )

    def test_weekendsonly_calendar(self):
        wocal = WeekendsOnly()
        first_date  = Date(31, Dec, 2014)
        Jan_1_2015 = Date(1, Jan, 2015)
        Jan_5_2015 = Date(5, Jan, 2015)
        period_1_day = Period(1, Days)
        period_3_day = Period(3, Days)
        #do not skip holidays
        self.assertEqual(Jan_1_2015, wocal.advance(first_date,
                                                    period=period_1_day,
                                                    convention=Following))
        #but skip weekend dates
        self.assertEqual(Jan_5_2015, wocal.advance(first_date,
                                                    period=period_3_day,
                                                    convention=Following))

class TestDateList(unittest.TestCase):

    def test_iteration_on_date_list(self):

        date_iterator = holiday_list(
            TARGET(), Date(1, Jan, 2000), Date(1, Jan, 2001)
        )

        holidays = [
            Date(21, Apr, 2000), Date(24, Apr, 2000),
            Date(1, May, 2000), Date(25, Dec, 2000),
            Date(26, Dec, 2000), Date(1, Jan, 2001)
        ]

        for date in date_iterator:
            self.assertIn(date, holidays)


if __name__ == '__main__':
    unittest.main()
