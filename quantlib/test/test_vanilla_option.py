import unittest

from quantlib.instruments.option import (
    Put, EuropeanExercise, AmericanExercise
)
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import VanillaOption
from quantlib.pricingengines.vanilla import (
    AnalyticEuropeanEngine, BaroneAdesiWhaleyApproximationEngine
)
from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.settings import Settings
from quantlib.time.api import Date, TARGET, May, Actual365Fixed
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote

from quantlib.termstructures.volatility.equityfx.black_vol_term_structure import BlackConstantVol


class VanillaOptionTestCase(unittest.TestCase):
    """Base test for all the cases related to VanillaOption.

    This test case is based on the QuantLib example EquityOption.cpp
    """

    def setUp(self):

        self.settings = Settings()

        self.calendar = TARGET()

        self.todays_date = Date(15, May, 1998)
        self.settlement_date = Date(17, May, 1998)

        self.settings.evaluation_date = self.todays_date

        # options parameters
        self.option_type = Put
        self.underlying = 36
        self.strike = 40
        self.dividend_yield = 0.00
        self.risk_free_rate = 0.06
        self.volatility = 0.20
        self.maturity = Date(17, May, 1999)
        self.daycounter = Actual365Fixed()

        self.underlyingH = SimpleQuote(self.underlying)

        # bootstrap the yield/dividend/vol curves
        self.flat_term_structure = FlatForward(
            reference_date = self.settlement_date,
            forward        = self.risk_free_rate,
            daycounter     = self.daycounter
        )
        self.flat_dividend_ts = FlatForward(
            reference_date = self.settlement_date,
            forward        = self.dividend_yield,
            daycounter     = self.daycounter
        )

        self.flat_vol_ts = BlackConstantVol(
            self.settlement_date,
            self.calendar,
            self.volatility,
            self.daycounter
        )

        self.black_scholes_merton_process = BlackScholesMertonProcess(
            self.underlyingH,
            self.flat_dividend_ts,
            self.flat_term_structure,
            self.flat_vol_ts
        )

        self.payoff = PlainVanillaPayoff(self.option_type, self.strike)


    def test_str(self):
        quote_str = str(self.underlyingH)
        self.assertEquals('Simple Quote: 36.000000', quote_str)

        payoff_str = str(self.payoff)
        self.assertEquals('Payoff: Vanilla Put @ 40.000000', payoff_str)

        exercise = EuropeanExercise(self.maturity)
        exercise_str = str(exercise)
        self.assertEquals('Exercise type: European', exercise_str)


        # FIXME: this crashes
        # option = VanillaOption(self.payoff, exercise)
        # print option.exercise
        # self.assertEquals('Exercise type: European', option.exercise)
        #vanilla_str = str(option)
        #self.assertEquals('Vanilla option', vanilla_str)

    def test_european_vanilla_option_usage(self):


        european_exercise = EuropeanExercise(self.maturity)
        european_option = VanillaOption(self.payoff, european_exercise)

        analytic_european_engine = AnalyticEuropeanEngine(
            self.black_scholes_merton_process
        )

        european_option.set_pricing_engine(analytic_european_engine)

        self.assertAlmostEquals(3.844308, european_option.net_present_value, 6)

    def test_american_vanilla_option(self):

        american_exercise = AmericanExercise(self.maturity)
        american_option = VanillaOption(self.payoff, american_exercise)

        engine = BaroneAdesiWhaleyApproximationEngine(
            self.black_scholes_merton_process
        )

        american_option.set_pricing_engine(engine)

        self.assertAlmostEquals(4.459628, american_option.net_present_value, 6)

    def test_american_vanilla_option_with_earliest_date(self):

        american_exercise = AmericanExercise(
            latest_exercise_date   = self.maturity,
            earliest_exercise_date = self.settlement_date
        )
        american_option = VanillaOption(self.payoff, american_exercise)

        engine = BaroneAdesiWhaleyApproximationEngine(
            self.black_scholes_merton_process
        )

        american_option.set_pricing_engine(engine)

        self.assertAlmostEquals(4.459628, american_option.net_present_value, 6)


    def test_american_vanilla_option_with_earliest_date_wrong_order(self):

        with self.assertRaises(RuntimeError):
            AmericanExercise(
                self.settlement_date,
                self.maturity
            )


if __name__ == '__main__':
    unittest.main()
