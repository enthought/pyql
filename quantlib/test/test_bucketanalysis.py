
from .unittest_tools import unittest

from quantlib.instruments.bonds import (FixedRateBond)
from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.time.calendar import ( Unadjusted, ModifiedFollowing, Following)
from quantlib.time.calendars.target import TARGET
from quantlib.time.calendars.united_states import ( UnitedStates, GOVERNMENTBOND)
from quantlib.currency.api import USDCurrency
from quantlib.instruments.option import VanillaOption
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.compounding import Compounded, Continuous
from quantlib.time.date import ( Date, Days, Semiannual, January, August, Period, March, February, May,Jul, Annual, Years)
from quantlib.time.api import (TARGET, Period, Months, Years, Days,September, ISDA, today, Mar,
    ModifiedFollowing, Unadjusted, Actual360, Thirty360, ActualActual, Actual365Fixed,
    Annual, UnitedStates, Months, Actual365Fixed)
from quantlib.time.daycounters.actual_actual import Bond, ISMA
from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.indexes.libor import Libor
from quantlib.instruments.option import (EuropeanExercise, AmericanExercise, DividendVanillaOption)
from quantlib.termstructures.yields.rate_helpers import (DepositRateHelper, SwapRateHelper)
from quantlib.termstructures.yields.piecewise_yield_curve import (VALID_TRAITS, VALID_INTERPOLATORS,PiecewiseYieldCurve)
from quantlib.termstructures.yields.api import (FlatForward, YieldTermStructure)
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure import BlackConstantVol
from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.pricingengines.vanilla.vanilla import (
    AnalyticEuropeanEngine, BaroneAdesiWhaleyApproximationEngine,
    FDDividendAmericanEngine
    )
from quantlib.instruments.payoffs import PlainVanillaPayoff, Put
import quantlib.pricingengines.bondfunctions as bf
from  quantlib.experimental.risk.sensitivityanalysis import bucket_analysis

class SensitivityTestCase(unittest.TestCase):

    #@unittest.skip('This test is not numerically accurate and fails')
    def test_bucketanalysis_bond(self):

        settings = Settings()

        calendar = TARGET()


        settlement_date = calendar.adjust(Date(28, January, 2011))
        simple_quotes = []

        fixing_days = 1
        settlement_days = 1

        todays_date = calendar.advance(
            settlement_date, -fixing_days, Days
        )

        settings.evaluation_date = todays_date

        face_amount = 100.0
        redemption = 100.0
        issue_date = Date(27, January, 2011)
        maturity_date = Date(1, January, 2021)
        coupon_rate = 0.055
        bond_yield = 0.034921

        flat_discounting_term_structure = YieldTermStructure(relinkable=True)
        flat_term_structure = FlatForward(
            reference_date = settlement_date,
            forward        = bond_yield,
            daycounter     = Actual365Fixed(), 
            compounding    = Compounded,
            frequency      = Semiannual)

        flat_discounting_term_structure.link_to(flat_term_structure)

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


        zspd=bf.zSpread(bond, 100.0, flat_term_structure, Actual365Fixed(),
        Compounded, Semiannual, settlement_date, 1e-6, 100, 0.5)

             
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
            sq_rate = SimpleQuote(rate/100)
            helper = DepositRateHelper(sq_rate, 
                        tenor, 
                        settlement_days,
                        calendar,
                        ModifiedFollowing,
                        end_of_month,
                        Actual360())
            simple_quotes.append(sq_rate)
            rate_helpers.append(helper)

        liborIndex = Libor('USD Libor', Period(6, Months), settlement_days,
                            USDCurrency(), calendar, Actual360(),
                            YieldTermStructure(relinkable=False))

        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)

        for m, period, rate in swapData:
            sq_rate = SimpleQuote(rate/100)
            helper = SwapRateHelper.from_tenor(
                sq_rate, Period(m, Years), calendar, Annual, Unadjusted, Thirty360(), liborIndex,
                spread, fwdStart
            )
            simple_quotes.append(sq_rate)
            rate_helpers.append(helper)

        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-15

        ts = PiecewiseYieldCurve(
            'discount', 'loglinear', settlement_date, rate_helpers,
            ts_day_counter, tolerance)   

        discounting_term_structure = YieldTermStructure(relinkable=True)
        discounting_term_structure.link_to(ts)
        pricing_engine = DiscountingBondEngine(discounting_term_structure)
        bond.set_pricing_engine(pricing_engine)
                                   
                                                            

        self.assertAlmostEqual(bond.npv, 100.83702940160767)
    

        ba =  bucket_analysis([simple_quotes], [bond], [1], 0.0001, 1)
        
        self.assertTrue(2, ba) 
        self.assertTrue(type(tuple), ba) 
        self.assertEqual(len(simple_quotes), len(ba[0][0]))
        self.assertEqual(0, ba[0][0][8])
    
    def test_bucket_analysis_option(self):
        
        settings = Settings()
        
        calendar = TARGET()
        
        todays_date = Date(15, May, 1998)
        settlement_date = Date(17, May, 1998)
        
        settings.evaluation_date = todays_date

        option_type = Put
        underlying = 40
        strike = 40
        dividend_yield = 0.00
        risk_free_rate = 0.001
        volatility = 0.20
        maturity = Date(17, May, 1999)
        daycounter = Actual365Fixed()
        
        underlyingH = SimpleQuote(underlying)
        
        payoff = PlainVanillaPayoff(option_type, strike)
        
        
        flat_term_structure = FlatForward(
            reference_date = settlement_date,
            forward        = risk_free_rate,
            daycounter     = daycounter
        )
        flat_dividend_ts = FlatForward(
            reference_date = settlement_date,
            forward        = dividend_yield,
            daycounter     = daycounter
        )
        
        flat_vol_ts = BlackConstantVol(
            settlement_date,
            calendar,
            volatility,
            daycounter
        )
        
        black_scholes_merton_process = BlackScholesMertonProcess(
            underlyingH,
            flat_dividend_ts,
            flat_term_structure,
            flat_vol_ts
        )
        
        european_exercise = EuropeanExercise(maturity)
        european_option = VanillaOption(payoff, european_exercise)
        analytic_european_engine = AnalyticEuropeanEngine(
                    black_scholes_merton_process
                )
        
        european_option.set_pricing_engine(analytic_european_engine)
        
        
        ba_eo= bucket_analysis(
                [[underlyingH]], [european_option], [1], 0.50, 1)

        self.assertTrue(2, ba_eo)
        self.assertTrue(type(tuple), ba_eo) 
        self.assertEqual(1, len(ba_eo[0][0]))
        self.assertEqual(-0.4582666150152517, ba_eo[0][0][0])

if __name__ == '__main__':
    unittest.main()
