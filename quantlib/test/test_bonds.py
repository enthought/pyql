from .unittest_tools import unittest

from quantlib.instruments.bonds import (
    FixedRateBond, ZeroCouponBond, FloatingRateBond
)
from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.time.calendars.united_states import (
    UnitedStates, GOVERNMENTBOND, SETTLEMENT
)
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.calendars.target import TARGET
from quantlib.compounding import Compounded, Continuous
from quantlib.time.date import (
    Date, Days, Semiannual, January, August, Period, March, February,Oct,Nov,
    Jul, Annual, Years, Quarterly
)
from quantlib.time.daycounters.simple import Actual365Fixed, Actual360
from quantlib.time.daycounters.actual_actual import ActualActual, Bond, ISMA
from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure
)
from quantlib.indexes.libor import Libor
from quantlib.currency.api import USDCurrency
from quantlib.time.api import Months, Unadjusted, Following, ModifiedFollowing
from quantlib.cashflow import Leg, SimpleLeg
from quantlib.cashflows.coupon_pricer import IborCouponPricer, BlackIborCouponPricer, set_coupon_pricer
from quantlib.termstructures.volatility.optionlet.optionlet_volatility_structure import ConstantOptionletVolatility, OptionletVolatilityStructure
from quantlib.indexes.euribor import Euribor6M

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


        print(settings.evaluation_date)
        print('Principal: {}'.format(face_amount))
        print('Issuing date: {} '.format(bond.issue_date))
        print('Maturity: {}'.format(bond.maturity_date))
        print('Coupon rate: {:.4%}'.format(coupon_rate))
        print('Yield: {:.4%}'.format(bond_yield))
        print('Net present value: {:.4f}'.format(bond.net_present_value))
        print('Clean price: {:.4f}'.format(bond.clean_price))
        print('Dirty price: {:.4f}'.format(bond.dirty_price))
        print('Accrued coupon: {:.6f}'.format(bond.accrued_amount()))
        print('Accrued coupon: {:.6f}'.format(
            bond.accrued_amount(Date(1, March, 2011))
        ))

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

        engine = DiscountingBondEngine(discounting_term_structure)

        bond.set_pricing_engine(engine)


        self.assertEqual(Date(10, Jul, 2016), termination_date)
        self.assertEqual(
            calendar.advance(todays_date, 3, Days), bond.settlement_date()
        )
        self.assertEqual(Date(11, Jul, 2016), bond.maturity_date)
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
            100.0, todays_date
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

        engine = DiscountingBondEngine(discounting_term_structure)

        bond.set_pricing_engine(engine)
        
        self.assertEqual(
            calendar.advance(todays_date, 3, Days), bond.settlement_date()
        )
        self.assertEqual(0., bond.accrued_amount(bond.settlement_date()))
        self.assertAlmostEqual(57.6915, bond.clean_price, 4)
    def test_excel_example_with_floating_rate_bond(self):
        
        todays_date = Date(25, August, 2011)

        settings = Settings()
        settings.evaluation_date =  todays_date

        calendar = TARGET()
        effective_date = Date(10, Jul, 2006)
        termination_date = calendar.advance(
            effective_date, 10, Years, convention=Unadjusted
        )

        settlement_date = calendar.adjust(Date(28, January, 2011))
        settlement_days = 3 #1
        face_amount = 13749769.27 #2
        coupon_rate = 0.05
        redemption = 100.0

        float_bond_schedule = Schedule(
            effective_date,
            termination_date,
            Period(Annual),
            calendar,
            ModifiedFollowing,
            ModifiedFollowing,
            Backward
        )#3
        
        flat_discounting_term_structure = YieldTermStructure(relinkable=True)
        forecastTermStructure = YieldTermStructure(relinkable=True)
        
        
        dc = Actual360()
        ibor_index = Euribor6M(forecastTermStructure) #5

        
        fixing_days = 2 #6
        gearings = [1,0.0] #7
        spreads = [1,0.05] #8
        caps = [] #9
        floors = [] #10
        pmt_conv = ModifiedFollowing #11

        issue_date = effective_date

        
        float_bond = FloatingRateBond(settlement_days, face_amount, float_bond_schedule, ibor_index, dc, 
                                    fixing_days, gearings, spreads, caps, floors, pmt_conv, redemption, issue_date)

        flat_term_structure = FlatForward(
            settlement_days = 1,
            forward         = 0.055,
            calendar        = NullCalendar(),
            daycounter      = Actual365Fixed(),
            compounding     = Continuous,
            frequency       = Annual)
        flat_discounting_term_structure.link_to(flat_term_structure)
        forecastTermStructure.link_to(flat_term_structure)
        
        engine = DiscountingBondEngine(flat_discounting_term_structure)
        
        float_bond.set_pricing_engine(engine)
        cons_option_vol = ConstantOptionletVolatility(settlement_days, UnitedStates(SETTLEMENT), pmt_conv, 0.95, Actual365Fixed())
        coupon_pricer = BlackIborCouponPricer(cons_option_vol)
        
        set_coupon_pricer(float_bond,coupon_pricer)
        

        self.assertEqual(Date(10, Jul, 2016), termination_date)
        self.assertEqual(
            calendar.advance(todays_date, 3, Days), float_bond.settlement_date()
        )
        self.assertEqual(Date(11, Jul, 2016), float_bond.maturity_date)
        self.assertAlmostEqual(
            0.6944, float_bond.accrued_amount(float_bond.settlement_date()), 4
        )
        self.assertAlmostEqual(98.2485, float_bond.dirty_price, 4)
        self.assertAlmostEqual(13500805.2469, float_bond.npv,4)


        
if __name__ == '__main__':
    unittest.main()
