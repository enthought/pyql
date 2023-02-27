import unittest

from quantlib.instruments.api import MakeVanillaSwap, FixedRateBond
from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.time.calendars.target import TARGET
from quantlib.time.calendars.united_states import UnitedStates, Market
from quantlib.instruments.option import (VanillaOption, Put,
                                         EuropeanExercise)
from quantlib.time.date import (
    Date, Days, Semiannual, January,
    Period, May, Annual, Years)
from quantlib.time.api import (Months, ISDA,
                               ModifiedFollowing, Unadjusted, Actual360,
                               Thirty360, ActualActual,
                               Actual365Fixed)
from quantlib.time.daycounters.actual_actual import Bond
from quantlib.time.schedule import Schedule
from quantlib.time.dategeneration import DateGeneration
from quantlib.settings import Settings
from quantlib.indexes.ibor.usdlibor import USDLibor
from quantlib.termstructures.yields.rate_helpers import (
    DepositRateHelper, SwapRateHelper)
from quantlib.termstructures.yields.piecewise_yield_curve \
    import PiecewiseYieldCurve
from quantlib.termstructures.yields.api import (
    FlatForward, BootstrapTrait)
from quantlib.math.interpolation import LogLinear
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.volatility.equityfx.black_constant_vol \
    import BlackConstantVol
from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.pricingengines.vanilla.vanilla import (
    AnalyticEuropeanEngine
)
from quantlib.instruments.payoffs import PlainVanillaPayoff
import quantlib.pricingengines.bondfunctions as bf
from quantlib.experimental.risk.sensitivityanalysis import (
    bucket_analysis, parallel_analysis, Centered)
from numpy.testing import assert_allclose

class SensitivityTestCase(unittest.TestCase):

    def setUp(self):
        self.calendar = TARGET()
        self.settlement_days = 1
        settlement_date = self.calendar.adjust(Date(28, January, 2011))
        todays_date = self.calendar.advance(
            settlement_date, -self.settlement_days, Days
        )
        Settings().evaluation_date = todays_date

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

        self.rate_helpers = []
        self.quotes = []

        end_of_month = True
        for m, period, rate in depositData:
            tenor = Period(m, Months)
            q = SimpleQuote(rate / 100)
            helper = DepositRateHelper(q,
                                       tenor,
                                       self.settlement_days,
                                       self.calendar,
                                       ModifiedFollowing,
                                       end_of_month,
                                       Actual360())
            self.quotes.append(q)
            self.rate_helpers.append(helper)

        liborIndex = USDLibor(Period(6, Months))

        for m, period, rate in swapData:
            sq_rate = SimpleQuote(rate/100)
            helper = SwapRateHelper.from_tenor(
                sq_rate, Period(m, Years), self.calendar, Annual, Unadjusted,
                Thirty360(), liborIndex
            )
            self.quotes.append(sq_rate)
            self.rate_helpers.append(helper)

        ts_day_counter = ActualActual(ISDA)
        tolerance = 1.0e-15

        self.ts = PiecewiseYieldCurve[BootstrapTrait.Discount, LogLinear](
            self.settlement_days,
            self.calendar, self.rate_helpers, ts_day_counter, accuracy=tolerance)

    def test_bucketanalysis_bond(self):

        face_amount = 100.0
        redemption = 100.0
        issue_date = Date(27, January, 2011)
        maturity_date = Date(1, January, 2021)
        coupon_rate = 0.055

        fixed_bond_schedule = Schedule.from_rule(
            issue_date,
            maturity_date,
            Period(Semiannual),
            UnitedStates(market=Market.GovernmentBond),
            Unadjusted,
            Unadjusted,
            DateGeneration.Backward,
            False)

        bond = FixedRateBond(
            self.settlement_days,
            face_amount,
            fixed_bond_schedule,
            [coupon_rate],
            ActualActual(Bond),
            Unadjusted,
            redemption,
            issue_date
        )

        pricing_engine = DiscountingBondEngine(self.ts)
        bond.set_pricing_engine(pricing_engine)

        self.assertAlmostEqual(bond.npv, 100.82127876105724)
        delta, gamma = bucket_analysis(self.quotes, [bond])
        self.assertEqual(len(self.quotes), len(delta))
        old_values = [q.value for q in self.quotes]
        delta_manual = []
        gamma_manual = []
        pv = bond.npv
        shift = 1e-4
        for v, q in zip(old_values, self.quotes):
            q.value = v + shift
            pv_plus = bond.npv
            q.value = v - shift
            pv_minus = bond.npv
            delta_manual.append((pv_plus - pv_minus) * 0.5 / shift)
            gamma_manual.append((pv_plus - 2 * pv + pv_minus) / shift ** 2)
            q.value = v
        assert_allclose(delta, delta_manual)
        assert_allclose(gamma, gamma_manual, atol=1e-4)

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
        volatility = SimpleQuote(0.20)
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


        delta, gamma = bucket_analysis(
            [underlyingH, volatility], [european_option], shift=1e-4,
            type=Centered)
        self.assertAlmostEqual(delta[0], european_option.delta)
        self.assertAlmostEqual(delta[1], european_option.vega)
        self.assertAlmostEqual(gamma[0], european_option.gamma, 5)

    def test_parallel_analysis(self):
        index = USDLibor(Period(3, Months), self.ts)
        swap = MakeVanillaSwap(Period(10, Years),
                               index)()
        old_values = [q.value for q in self.quotes]
        dv01, _ = parallel_analysis(self.quotes, [swap])
        shift = 1e-4

        for v, q in zip(old_values, self.quotes):
            q.value = v + shift
        pv_plus = swap.npv

        for v, q in zip(old_values, self.quotes):
            q.value = v - shift
        pv_minus = swap.npv

        self.assertAlmostEqual((pv_plus - pv_minus) * 0.5 / shift, dv01)

if __name__ == '__main__':
    unittest.main()
