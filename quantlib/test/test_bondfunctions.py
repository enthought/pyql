
from .unittest_tools import unittest

from quantlib.instruments.bonds import (
    FixedRateBond, ZeroCouponBond
)
from quantlib.pricingengines import DiscountingBondEngine
from quantlib.time.calendar import (
    Unadjusted, ModifiedFollowing, Following
)
from quantlib.time.calendars.united_states import (
    UnitedStates, GOVERNMENTBOND
)
from quantlib.currency import USDCurrency

from quantlib.time.calendars import (NullCalendar, TARGET)
from quantlib.compounding import Compounded, Continuous
from quantlib.time.date import (
    Date, Days, Semiannual, January, August, Period, March, February, April, May,
    Jul, Annual, Years
)
from quantlib.time import (Period, Months, Years, Days,September, ISDA, today, Mar,
    ModifiedFollowing, Unadjusted, Annual, Months)
from quantlib.time.daycounters import *
from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.indexes import Libor

from quantlib.termstructures.yields import (
    DepositRateHelper, SwapRateHelper, FlatForward, YieldTermStructure)
from quantlib.termstructures.yields.piecewise_yield_curve import (
    VALID_TRAITS, VALID_INTERPOLATORS,
    PiecewiseYieldCurve)

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
        
        

        d=bf.startDate(bond)

        zspd=bf.zSpread(bond, 100.0, flat_term_structure, Actual365Fixed(),
        Compounded, Semiannual, settlement_date, 1e-6, 100, 0.5)
        

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

            helper = DepositRateHelper(SimpleQuote(rate/100), tenor, settlement_days,
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
                SimpleQuote(rate/100), Period(m, Years), calendar, Annual, Unadjusted, Thirty360(), liborIndex,
                spread, fwdStart
            )

            rate_helpers.append(helper)

        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-15

        ts = PiecewiseYieldCurve(
            'discount', 'loglinear', settlement_date, rate_helpers,
            ts_day_counter, tolerance)   

        pyc_zspd=bf.zSpread(bond, 102.0, ts, ActualActual(ISDA),
        Compounded, Semiannual, Date(1, April, 2015), 1e-6, 100, 0.5)                                      

        pyc_zspd_disco=bf.zSpread(bond, 95.0, ts, ActualActual(ISDA),
        Compounded, Semiannual, settlement_date, 1e-6, 100, 0.5)                                      
        

        yld  = bf.yld(bond, 102.0, ActualActual(ISDA), Compounded, Semiannual, settlement_date, 1e-6, 100, 0.5)
        dur  = bf.duration(bond, yld, ActualActual(ISDA), Compounded, Semiannual, 2, settlement_date) 

        yld_disco  = bf.yld(bond, 95.0, ActualActual(ISDA), Compounded, Semiannual, settlement_date, 1e-6, 100, 0.5)
        dur_disco  = bf.duration(bond, yld_disco, ActualActual(ISDA), Compounded, Semiannual, 2, settlement_date)        
        
        self.assertEqual(round(zspd, 6), 0.001281)
        self.assertEqual(round(pyc_zspd, 4), -0.0264)
        self.assertEqual(round(pyc_zspd_disco, 4), -0.0114)
        
        self.assertEqual(round(yld, 4), 0.0338)
        self.assertEqual(round(yld_disco, 4), 0.0426)
        
        self.assertEqual(round(dur, 4), 8.0655)
        self.assertEqual(round(dur_disco, 4), 7.9702)



if __name__ == '__main__':
    unittest.main()
