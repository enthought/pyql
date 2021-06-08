from .unittest_tools import unittest

from quantlib.instruments.option import EuropeanExercise

from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import Put
from quantlib.instruments.asian_options import ContinuousAveragingAsianOption, Geometric
from quantlib.pricingengines.asian.analyticcontgeomavprice import (
    AnalyticContinuousGeometricAveragePriceAsianEngine
)

from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.settings import Settings
from quantlib.time.api import Date, NullCalendar, June, Actual360
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.volatility.api import BlackConstantVol


class AsianOptionTestCase(unittest.TestCase):
    """Base test for all the cases related to VanillaOption.

    This test case is based on the QuantLib example EquityOption.cpp
    """

    def setUp(self):

        self.settings = Settings()

        self.calendar = NullCalendar()

        self.todays_date = Date(6, June, 2021)
        self.settlement_date = self.todays_date + 90

        self.settings.evaluation_date = self.todays_date

        # options parameters
        self.option_type = Put
        self.underlying = 80.0
        self.strike = 85.0
        self.dividend_yield = -0.03
        self.risk_free_rate = 0.05
        self.volatility = 0.20
        # self.maturity = Date(17, May, 1999)
        self.daycounter = Actual360()

        self.underlyingH = SimpleQuote(self.underlying)

        # bootstrap the yield/dividend/vol curves
        self.flat_term_structure = FlatForward(
            reference_date=self.todays_date,
            forward=self.risk_free_rate,
            daycounter=self.daycounter
        )
        self.flat_dividend_ts = FlatForward(
            reference_date=self.todays_date,
            forward=self.dividend_yield,
            daycounter=self.daycounter
        )

        self.flat_vol_ts = BlackConstantVol(
            self.todays_date,
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

        #Additional parameters for testing DividendVanillaOption
        #self.dividend_dates = []
        #self.dividends = []
        #self.american_time_steps = 600
        #self.american_grid_points = 600

        #Parameters for implied volatility:
        #self.accuracy = 0.001
        #self.max_evaluations = 1000
        #self.min_vol = 0.001
        #self.max_vol = 4
        #self.target_price = 4.485992

    def test_analytic_cont_geom_av_price(self):
        """
        "Testing analytic continuous geometric average-price Asians...");
        
        data from "Option Pricing Formulas", Haug, pag.96-97
        """
        exercise = EuropeanExercise(self.settlement_date)
        
        option = ContinuousAveragingAsianOption(Geometric, self.payoff, exercise)

        engine = AnalyticContinuousGeometricAveragePriceAsianEngine(
            self.black_scholes_merton_process
        )

        option.set_pricing_engine(engine)

        tolerance = 1.0e-4

        self.assertAlmostEqual(4.6922, option.net_present_value, delta=tolerance)
    
    # trying to approximate the continuous version with the discrete version
    #runningAccumulator = 1.0;
    #pastFixings = 0;
    ##fixingDates(exerciseDate-today+1);
    #for (Size i=0; i<fixingDates.size(); i++) {
    #    fixingDates[i] = today + i;
    #}
    #engine2 = AnalyticDiscreteGeometricAveragePriceAsianEngine(stochProcess))
    
    #DiscreteAveragingAsianOption option2(averageType,
    #                                     runningAccumulator, pastFixings,
    #                                     fixingDates,
    #                                     payoff,
    #                                     exercise);
    #option2.setPricingEngine(engine2);

    #calculated = option2.NPV();
    #tolerance = 3.0e-3;
    #if (std::fabs(calculated-expected) > tolerance) {
    #    REPORT_FAILURE("value", averageType, runningAccumulator, pastFixings,
    #                   fixingDates, payoff, exercise, spot->value(),
    #                   qRate->value(), rRate->value(), today,
    #                   vol->value(), expected, calculated, tolerance);
    #}

        
