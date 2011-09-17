import unittest

from quantlib.instruments.bonds import (
    FixedRateBond, ZeroCouponBond
)
from quantlib.time.calendar import (
    TARGET, Unadjusted, ModifiedFollowing, Following
)
from quantlib.time.calendars.united_states import (
    UnitedStates, GOVERNMENTBOND
)
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.compounding import Compounded, Continuous
from quantlib.time.date import (
    Date, Days, Semiannual, January, August, Period, June, March, February, 
    Jul, Annual, today, Years, August, today
)
from quantlib.time.daycounter import Actual365Fixed
from quantlib.time.daycounters.actual_actual import ActualActual, Bond, ISMA
from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.termstructures.yields.flat_forward import (
    FlatForward, YieldTermStructure
)

class BondTestCase(unittest.TestCase):

    @unittest.skip('This test is not numerically accurate and fails')
    def test_pricing_bond(self):
        '''Inspired by the C++ code from http://quantcorner.wordpress.com/.'''

        settings = Settings()

        # Date setup
        calendar = TARGET()

        # Settlement date
        settlement_date = calendar.adjust(Date(28, January, 2011))

        # Evaluation date
        fixing_days = 1
        settlement_days = 1

        todays_date = calendar.advance(
            settlement_date, -fixing_days, Days
        )

        settings.evaluation_date = todays_date

        # Bound attributes
        face_amount = 100.0
        redemption = 100.0
        issue_date = Date(27, January, 2011)
        maturity_date = Date(31, August, 2020)
        coupon_rate = 0.03625
        bond_yield = 0.034921 

        discounting_term_structure = YieldTermStructure(relinkable=True)
        flat_term_structure = FlatForward(
            reference_date = settlement_date,
            forward        = bond_yield, 
            daycounter     = Actual365Fixed(), #actual_actual.ActualActual(actual_actual.Bond), 
            compounding    = Compounded,
            frequency      = Semiannual)
        # have a look at the FixedRateBondHelper to simplify this 
        # construction
        discounting_term_structure.link_to(flat_term_structure)


	    #Rate
        fixed_bond_schedule = Schedule(
            issue_date,
            maturity_date,
            Period(Semiannual),
            UnitedStates(market=GOVERNMENTBOND),
            Unadjusted,
            Unadjusted,
            Backward,
            False);


        bond = FixedRateBond(
            settlement_days,
		    face_amount,
		    fixed_bond_schedule,
		    [coupon_rate],
            ActualActual(Bond), 
		    Unadjusted,
            redemption,
            issue_date
        )

        bond.set_pricing_engine(discounting_term_structure)

        # tests
        self.assertTrue(Date(27, January, 2011), bond.issue_date)
        self.assertTrue(Date(31, August, 2020), bond.maturity_date)
        self.assertTrue(settings.evaluation_date, bond.valuation_date)

        # the following assertion fails but must be verified
        self.assertAlmostEqual(101.1, bond.clean_price, 1)
        self.assertAlmostEqual(101.1, bond.net_present_value, 1)
        self.assertAlmostEqual(101.1, bond.dirty_price)
        self.assertAlmostEqual(0.009851, bond.accrued_amount())

        
        print settings.evaluation_date
        print 'Principal: {}'.format(face_amount)
        print 'Issuing date: {} '.format(bond.issue_date)
        print 'Maturity: {}'.format(bond.maturity_date)
        print 'Coupon rate: {:.4%}'.format(coupon_rate)
        print 'Yield: {:.4%}'.format(bond_yield)
        print 'Net present value: {:.4f}'.format(bond.net_present_value)
        print 'Clean price: {:.4f}'.format(bond.clean_price)
        print 'Dirty price: {:.4f}'.format(bond.dirty_price)
        print 'Accrued coupon: {:.6f}'.format(bond.accrued_amount())
        print 'Accrued coupon: {:.6f}'.format(
            bond.accrued_amount(Date(1, March, 2011))
        )

    def test_excel_example_with_fixed_rate_bond(self):
        '''Port the QuantLib Excel adding bond example to Python. '''

        
        todays_date = Date(25, August, 2011)


        settings = Settings()
        settings.evaluation_date =  todays_date

        calendar = TARGET()
        effective_date = Date(10, Jul, 2006)
        termination_date = calendar.advance(
            effective_date, 10, Years, convention=Unadjusted
        )


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

        discounting_term_structure = YieldTermStructure(relinkable=True)
        flat_term_structure = FlatForward(
            settlement_days = 1,
            forward         = 0.044, 
            calendar        = NullCalendar(), 
            daycounter      = Actual365Fixed(),
            compounding     = Continuous,
            frequency       = Annual)
        discounting_term_structure.link_to(flat_term_structure)

        bond.set_pricing_engine(discounting_term_structure)


        self.assertEquals(Date(10, Jul, 2016), termination_date)
        self.assertEquals(
            calendar.advance(todays_date, 3, Days), bond.settlement_date() 
        )
        self.assertEquals(Date(11, Jul, 2016), bond.maturity_date)
        self.assertAlmostEqual(
            0.6849, bond.accrued_amount(bond.settlement_date()), 4
        )
        self.assertAlmostEqual(102.1154, bond.clean_price, 4)


    def test_excel_example_with_zero_coupon_bond(self):

        todays_date = Date(25, August, 2011)

        settlement_days = 3
        face_amount = 100
        calendar = TARGET()
        maturity_date = Date(26, February, 2024)

        bond = ZeroCouponBond(
            settlement_days, calendar, face_amount, maturity_date, Following, 
            100., todays_date
        )

        discounting_term_structure = YieldTermStructure(relinkable=True)
        flat_term_structure = FlatForward(
            settlement_days = 1,
            forward         = 0.044, 
            calendar        = NullCalendar(), 
            daycounter      = Actual365Fixed(),
            compounding     = Continuous,
            frequency       = Annual)
        discounting_term_structure.link_to(flat_term_structure)

        bond.set_pricing_engine(discounting_term_structure)

        self.assertEquals(
            calendar.advance(todays_date, 3, Days), bond.settlement_date() 
        )
        self.assertEquals(0., bond.accrued_amount(bond.settlement_date())) 
        self.assertAlmostEquals(57.6915, bond.clean_price, 4)

if __name__ == '__main__':
    unittest.main()
