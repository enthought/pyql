
from .unittest_tools import unittest

from quantlib.instruments.bonds import (
    FixedRateBond, ZeroCouponBond
)
from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.time.calendar import (
    TARGET, Unadjusted, ModifiedFollowing, Following
)
from quantlib.time.calendars.united_states import (
    UnitedStates, GOVERNMENTBOND
)
from quantlib.currency.api import USDCurrency

from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.compounding import Compounded, Continuous
from quantlib.time.date import (
    Date, Days, Semiannual, January, August, Period, March, February,
    Jul, Annual, Years
)
from quantlib.time.api import (TARGET, Period, Months, Years, Days,September, ISDA, today, Mar,
    ModifiedFollowing, Unadjusted, Actual360, Thirty360, ActualActual, Actual365Fixed,
    Annual, UnitedStates, Months, Actual365Fixed)
from quantlib.time.daycounters.actual_actual import Bond, ISMA
from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.indexes.libor import Libor

from quantlib.termstructures.yields.rate_helpers import (
    DepositRateHelper, SwapRateHelper)
from quantlib.termstructures.yields.piecewise_yield_curve import (
    PiecewiseYieldCurve
)
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure
)
from quantlib.quotes import SimpleQuote

import quantlib.pricingengines.bondfunctions as bf


class BondFunctionTestCase(unittest.TestCase):

    #@unittest.skip('This test is not numerically accurate and fails')
    def test_display(self):

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

        flat_discounting_term_structure = YieldTermStructure(relinkable=True)
        flat_term_structure = FlatForward(
            reference_date = settlement_date,
            forward        = bond_yield,
            daycounter     = Actual365Fixed(), #actual_actual.ActualActual(actual_actual.Bond),
            compounding    = Compounded,
            frequency      = Semiannual)
        # have a look at the FixedRateBondHelper to simplify this
        # construction
        flat_discounting_term_structure.link_to(flat_term_structure)


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

        bfs=bf.BondFunctions()
        d=bfs.startDate(bond)
        bfs.display()
        zspd=bfs.zSpread(bond,100.0,flat_term_structure,Actual365Fixed(),
        Compounded,Semiannual,settlement_date,1e-6,100,0.5)
        
        
              
        #Also need a test case for a PiecewiseTermStructure...                
        depositData = [[ 1, Months, 4.581 ],
                       [ 2, Months, 4.573 ],
                       [ 3, Months, 4.557 ],
                       [ 6, Months, 4.496 ],
                       [ 9, Months, 4.490 ]]

        swapData = [[ 1, Years, 4.54 ],
                    [ 5, Years, 4.99 ],
                    [ 10, Years, 5.47 ],
                    [ 20, Years, 5.89 ],
                    [ 30, Years, 5.96 ]]

        rate_helpers = []

        end_of_month = True
        for m, period, rate in depositData:
            tenor = Period(m, Months)

            helper = DepositRateHelper(rate/100, tenor, settlement_days,
                     calendar, ModifiedFollowing, end_of_month,
                     Actual360())

            rate_helpers.append(helper)

        liborIndex = Libor('USD Libor', Period(6, Months), settlement_days,
                           USDCurrency(), calendar, Actual360(),
                           YieldTermStructure(relinkable=False))

        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)

        for m, period, rate in swapData:

            helper = SwapRateHelper.from_tenor(
                rate/100, Period(m, Years), calendar, Annual, Unadjusted, Thirty360(), liborIndex,
                spread, fwdStart
            )

            rate_helpers.append(helper)

        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-15

        ts = PiecewiseYieldCurve(
            'discount', 'loglinear', settlement_date, rate_helpers,
            ts_day_counter, tolerance)   

        pyc_zspd=bfs.zSpread(bond,102.0,ts,ActualActual(ISDA),
        Compounded,Semiannual,settlement_date,1e-6,100,0.5)                     

        pyc_zspd_disco=bfs.zSpread(bond,95.0,ts,ActualActual(ISDA),
        Compounded,Semiannual,settlement_date,1e-6,100,0.5)
                                                          
        # tests
        #self.assertTrue(Date(27, January, 2011), bond.issue_date)
        #self.assertTrue(Date(31, August, 2020), bond.maturity_date)
        #self.assertTrue(settings.evaluation_date, bond.valuation_date)

        print d
        self.assertTrue(Date(27, January, 2011), d)

        print 'Yield: {:.15%}'.format(bond_yield)
        #self.assertTrue(bond_yield,
        print 'Yield: {:.4%}'.format(bond_yield)
        print 'z-spread: {:.4%}'.format(zspd)
        print 'premium  z-spread using pwyc: {:.4%}'.format(pyc_zspd)
        print 'discount z-spread using pwyc: {:.4%}'.format(pyc_zspd_disco)
#        print 'Net present value: {:.4f}'.format(bond.net_present_value)
#        print 'Clean price: {:.4f}'.format(bond.clean_price)
#        print 'Dirty price: {:.4f}'.format(bond.dirty_price)
#        print 'Accrued coupon: {:.6f}'.format(bond.accrued_amount())
#        print 'Accrued coupon: {:.6f}'.format(
#            bond.accrued_amount(Date(1, March, 2011))
#        )


if __name__ == '__main__':
    unittest.main()
