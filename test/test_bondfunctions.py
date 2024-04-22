
import unittest

from quantlib.instruments.bonds import (
    FixedRateBond, ZeroCouponBond
)
from quantlib.time.calendars.united_states import (
    UnitedStates, Market
)
from quantlib.currency.api import USDCurrency

from quantlib.compounding import Compounded, Continuous
from quantlib.instruments.bond import Price
from quantlib.time.date import (
    Date, Days, Years, January, August, Period, April
)
from quantlib.time.api import (TARGET, Months, ISDA,
    ModifiedFollowing, Unadjusted, Actual360, Thirty360, ActualActual, Actual365Fixed,
    Annual, Months, Actual365Fixed, Annual, Semiannual)
from quantlib.time.daycounters.actual_actual import Bond
from quantlib.time.schedule import Schedule
from quantlib.time.dategeneration import DateGeneration
from quantlib.settings import Settings
from quantlib.indexes.ibor.libor import Libor

from quantlib.termstructures.yields.rate_helpers import (
    DepositRateHelper, SwapRateHelper)
from quantlib.termstructures.yields.piecewise_yield_curve import PiecewiseYieldCurve
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure, BootstrapTrait
)
from quantlib.math.interpolation import LogLinear
from quantlib.quotes import SimpleQuote

import quantlib.pricingengines.bond.bondfunctions as bf


class BondFunctionTestCase(unittest.TestCase):

    def setUp(self):
        settings = Settings()

        # Date setup
        self.calendar = TARGET()

        # Settlement date
        self.settlement_date = self.calendar.adjust(Date(28, January, 2011))

        # Evaluation date
        fixing_days = 1
        self.settlement_days = 1

        todays_date = self.calendar.advance(
            self.settlement_date, -fixing_days, Days
        )

        settings.evaluation_date = todays_date

        # Bound attributes
        face_amount = 100.0
        redemption = 100.0
        issue_date = Date(27, January, 2011)
        maturity_date = Date(31, August, 2020)
        coupon_rate = 0.03625
        bond_yield = 0.034921

        self.flat_term_structure = FlatForward(
            reference_date = self.settlement_date,
            forward        = bond_yield,
            daycounter     = Actual365Fixed(), #actual_actual.ActualActual(actual_actual.Bond),
            compounding    = Compounded,
            frequency      = Semiannual)


	#Rate
        fixed_bond_schedule = Schedule.from_rule(
            issue_date,
            maturity_date,
            Period(Semiannual),
            UnitedStates(market=Market.GovernmentBond),
            Unadjusted,
            Unadjusted,
            DateGeneration.Backward,
            False);


        self.bond = FixedRateBond(
            self.settlement_days,
	    face_amount,
	    fixed_bond_schedule,
	    [coupon_rate],
            ActualActual(Bond),
	    Unadjusted,
            redemption,
            issue_date
        )

    def test_display(self):

        d = bf.start_date(self.bond)

        zspd = bf.zSpread(self.bond, Price(100.0), self.flat_term_structure, Actual365Fixed(),
        Compounded, Semiannual, self.settlement_date, 1e-6, 100, 0.5)


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

            helper = DepositRateHelper(SimpleQuote(rate/100), tenor, self.settlement_days,
                     self.calendar, ModifiedFollowing, end_of_month,
                     Actual360())

            rate_helpers.append(helper)

        liborIndex = Libor('USD Libor', Period(6, Months), self.settlement_days,
                           USDCurrency(), self.calendar, Actual360(),
                           YieldTermStructure(relinkable=False))

        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)

        for m, period, rate in swapData:

            helper = SwapRateHelper.from_tenor(
                SimpleQuote(rate/100), Period(m, Years), self.calendar, Annual, Unadjusted, Thirty360(), liborIndex,
                spread, fwdStart
            )

            rate_helpers.append(helper)

        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-15

        ts = PiecewiseYieldCurve[BootstrapTrait.Discount, LogLinear].from_reference_date(
            self.settlement_date, rate_helpers,
            ts_day_counter, accuracy=tolerance)

        pyc_zspd=bf.zSpread(self.bond, Price(102.0), ts, ActualActual(ISDA),
        Compounded, Semiannual, Date(1, April, 2015), 1e-6, 100, 0.05)

        pyc_zspd_disco=bf.zSpread(self.bond, Price(95.0), ts, ActualActual(ISDA),
        Compounded, Semiannual, self.settlement_date, 1e-6, 100, 0.05)


        yld  = bf.bond_yield(self.bond, Price(102.0), ActualActual(ISDA), Compounded, Semiannual, self.settlement_date, 1e-6, 100, 0.05)
        dur  = bf.duration(self.bond, yld, ActualActual(ISDA), Compounded, Semiannual, settlement_date=self.settlement_date)

        yld_disco  = bf.bond_yield(self.bond, Price(95.0), ActualActual(ISDA), Compounded, Semiannual, self.settlement_date, 1e-6, 100, 0.05)
        dur_disco  = bf.duration(self.bond, yld_disco, ActualActual(ISDA), Compounded, Semiannual, settlement_date=self.settlement_date)

        self.assertAlmostEqual(zspd, 0.001281, 6)
        self.assertAlmostEqual(pyc_zspd, -0.0264, 4)
        self.assertAlmostEqual(pyc_zspd_disco, -0.0114, 4)

        self.assertAlmostEqual(yld, 0.0338, 4)
        self.assertAlmostEqual(yld_disco, 0.0426, 4)

        self.assertAlmostEqual(dur, 8.0655, 3)
        self.assertAlmostEqual(dur_disco, 7.9702, 4)

    def test_cashflows(self):
        l = [Date(31, 8, 2017), Date(28, 2, 2017)]
        for d, cf in zip(l, bf.previous_cash_flow(self.bond, Date(10, 9, 2017))):
            self.assertEqual(cf.date, d, cf.date)



if __name__ == '__main__':
    unittest.main()
