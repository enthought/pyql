from .unittest_tools import unittest
from quantlib.instruments.bonds import FixedRateBond
from quantlib.time.api import (
    Date, Days, August, Period, Jul, Annual, today, Years, TARGET,
    Unadjusted, Schedule, ModifiedFollowing, Backward, ActualActual, ISMA,
    Following
)

from quantlib.settings import Settings

class SettingsTestCase(unittest.TestCase):

    def test_using_settings(self):

        settings = Settings()

        evaluation_date = today()

        # have to set the evaluation date before the test as it is a global
        # attribute for the whole library ... meaning that previous test_cases
        # might have set this to another date
        settings.evaluation_date = evaluation_date

        self.assertTrue(
            evaluation_date == settings.evaluation_date
        )

        self.assertTrue(settings.version.startswith('1'))

    def test_settings_instance_method(self):

        Settings.instance().evaluation_date = today()

        self.assertEqual(
                today(),
                Settings.instance().evaluation_date
        )


    def test_bond_schedule_today(self):
        '''Test date calculations and role of settings when evaluation date 
        set to current date. 

        
        '''
        
        todays_date = today()

        settings = Settings()
        settings.evaluation_date =  todays_date

        calendar = TARGET()
        effective_date = Date(10, Jul, 2006)
        termination_date = calendar.advance(
            effective_date, 10, Years, convention=Unadjusted)

        settlement_days = 3
        face_amount = 100.0
        coupon_rate = 0.05
        redemption = 100.0
        
        fixed_bond_schedule = Schedule(
            effective_date,
            termination_date,
            Period(Annual),
            calendar,
            ModifiedFollowing,
            ModifiedFollowing,
            Backward
        )

        issue_date = effective_date

        bond = FixedRateBond(
            settlement_days,
		    face_amount,
		    fixed_bond_schedule,
		    [coupon_rate],
            ActualActual(ISMA), 
		    Following,
            redemption,
            issue_date
        )

        self.assertEqual(
            calendar.advance(todays_date, 3, Days), bond.settlement_date())

    def test_bond_schedule_anotherday(self):
        '''Test date calculations and role of settings when evaluation date 
        set to arbitrary date. 

        This test is known to fail with boost 1.42.
        
        '''
        
        todays_date = Date(30, August, 2011) 

        settings = Settings()
        settings.evaluation_date =  todays_date

        calendar = TARGET()
        effective_date = Date(10, Jul, 2006)
        termination_date = calendar.advance(
            effective_date, 10, Years, convention=Unadjusted)

        settlement_days = 3
        face_amount = 100.0
        coupon_rate = 0.05
        redemption = 100.0
        
        fixed_bond_schedule = Schedule(
            effective_date,
            termination_date,
            Period(Annual),
            calendar,
            ModifiedFollowing,
            ModifiedFollowing,
            Backward
        )

        issue_date = effective_date

        bond = FixedRateBond(
            settlement_days,
		    face_amount,
		    fixed_bond_schedule,
		    [coupon_rate],
            ActualActual(ISMA), 
		    Following,
            redemption,
            issue_date
        )

        self.assertEqual(
            calendar.advance(todays_date, 3, Days), bond.settlement_date())
       
    def test_bond_schedule_anotherday_bug_cython_implementation(self):

        import quantlib.test.test_cython_bug as tcb

        date1, date2  = tcb.test_bond_schedule_today_cython()
        self.assertEqual(date1, date2)
        
        date1, date2  = tcb.test_bond_schedule_anotherday_cython()
        self.assertEqual(date1, date2)
    

