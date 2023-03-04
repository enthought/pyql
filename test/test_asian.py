from itertools import product

from quantlib.instruments.exercise import EuropeanExercise

from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import OptionType
from quantlib.instruments.asian_options import (
    ContinuousAveragingAsianOption, DiscreteAveragingAsianOption, AverageType
)
from quantlib.pricingengines.asian.analyticcontgeomavprice import (
    AnalyticContinuousGeometricAveragePriceAsianEngine
)
from quantlib.pricingengines.asian.analyticdiscrgeomavprice import (
    AnalyticDiscreteGeometricAveragePriceAsianEngine
)

from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.settings import Settings
from quantlib.time.api import Date, NullCalendar, June, Actual360, Years
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.volatility.api import BlackConstantVol

import unittest

from .utilities import flat_rate

def relative_error(x1, x2, reference):
    if reference:
        result = abs(x1-x2)/reference
    else:
        # fall back to absolute error
        result = abs(x1-x2)
    return result


class AsianOptionTestCase(unittest.TestCase):
    """Base test for all the cases related to VanillaOption.

    This test case is based on the QuantLib example EquityOption.cpp
    """

    def setUp(self):

        self.settings = Settings()

        self.calendar = NullCalendar()

        self.today = Date(6, June, 2021)
        self.settlement_date = self.today + 90

        self.settings.evaluation_date = self.today

        # options parameters
        self.option_type = OptionType.Put
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
            reference_date=self.today,
            forward=self.risk_free_rate,
            daycounter=self.daycounter
        )
        self.flat_dividend_ts = FlatForward(
            reference_date=self.today,
            forward=self.dividend_yield,
            daycounter=self.daycounter
        )

        self.flat_vol_ts = BlackConstantVol(
            self.today,
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


    def test_analytic_cont_geom_av_price(self):
        """
        "Testing analytic continuous geometric average-price Asians...")

        data from "Option Pricing Formulas", Haug, pag.96-97
        """
        exercise = EuropeanExercise(self.settlement_date)

        option = ContinuousAveragingAsianOption(AverageType.Geometric, self.payoff, exercise)

        engine = AnalyticContinuousGeometricAveragePriceAsianEngine(
            self.black_scholes_merton_process
        )

        option.set_pricing_engine(engine)

        tolerance = 1.0e-4

        self.assertAlmostEqual(4.6922, option.net_present_value, delta=tolerance)

        # trying to approximate the continuous version with the discrete version
        running_accumulator = 1.0
        past_fixings = 0

        fixing_dates = [self.today + i for i in range(91)]

        engine2 = AnalyticDiscreteGeometricAveragePriceAsianEngine(
            self.black_scholes_merton_process
        )

        option2 = DiscreteAveragingAsianOption(
            AverageType.Geometric,
            self.payoff,
            exercise,
            fixing_dates,
            past_fixings=past_fixings,
            running_accum=running_accumulator,
        )

        option2.set_pricing_engine(engine2)

        tolerance = 3.0e-3

        self.assertAlmostEqual(4.6922, option.net_present_value, delta=tolerance)


    def test_analytic_cont_geo_av_price_greeks(self):

        tolerance = {}
        tolerance["delta"]  = 1.0e-5
        tolerance["gamma"]  = 1.0e-5
        # tolerance["theta"]  = 1.0e-5
        tolerance["rho"]    = 1.0e-5
        tolerance["divRho"] = 1.0e-5
        tolerance["vega"]   = 1.0e-5

        opt_types = [OptionType.Call, OptionType.Put]
        underlyings = [100.0]
        strikes = [90.0, 100.0, 110.0]
        q_rates = [0.04, 0.05, 0.06]
        r_rates = [0.01, 0.05, 0.15]
        lengths = [1, 2]
        vols = [0.11, 0.50, 1.20]

        spot = SimpleQuote(0.0)
        q_rate = SimpleQuote(0.0)
        r_rate = SimpleQuote(0.0)
        vol = SimpleQuote(0.0)

        q_ts = flat_rate(q_rate, self.daycounter)
        r_ts =  flat_rate(r_rate, self.daycounter)
        vol_ts = BlackConstantVol(self.today, self.calendar, vol, self.daycounter)

        process = BlackScholesMertonProcess(spot, q_ts, r_ts, vol_ts)

        calculated = {}
        expected = {}
        for opt_type, strike, length in product(opt_types, strikes, lengths):

            maturity = EuropeanExercise(self.today + length*Years)

            payoff = PlainVanillaPayoff(opt_type, strike)

            engine = AnalyticContinuousGeometricAveragePriceAsianEngine(process)

            option = ContinuousAveragingAsianOption(AverageType.Geometric, payoff, maturity)

            option.set_pricing_engine(engine)

            for u, m, n, v in product(underlyings, q_rates, r_rates, vols):

                q = m
                r = n
                spot.value = u
                q_rate.value = q
                r_rate.value = r
                vol.value = v

                value = option.npv
                calculated["delta"] = option.delta
                calculated["gamma"] = option.gamma
                # calculated["theta"] = option.theta
                calculated["rho"] = option.rho
                calculated["divRho"] = option.dividend_rho
                calculated["vega"] = option.vega

                if (value > spot.value*1.0e-5):
                    # perturb spot and get delta and gamma
                    du = u*1.0e-4
                    spot.value = u + du
                    value_p = option.npv
                    delta_p = option.delta
                    spot.value = u - du
                    value_m = option.npv
                    delta_m = option.delta
                    spot.value = u
                    expected["delta"] = (value_p - value_m)/(2*du)
                    expected["gamma"] = (delta_p - delta_m)/(2*du)

                    # perturb rates and get rho and dividend rho
                    dr = r*1.0e-4
                    r_rate.value = r + dr
                    value_p = option.npv
                    r_rate.value = r - dr
                    value_m = option.npv
                    r_rate.value = r
                    expected["rho"] = (value_p - value_m)/(2*dr)

                    dq = q*1.0e-4
                    q_rate.value = q + dq
                    value_p = option.npv
                    q_rate.value = q - dq
                    value_m = option.npv
                    q_rate.value = q
                    expected["divRho"] = (value_p - value_m)/(2*dq)

                    # perturb volatility and get vega
                    dv = v*1.0e-4
                    vol.value = v + dv
                    value_p = option.npv
                    vol.value = v - dv
                    value_m = option.npv
                    vol.value = v
                    expected["vega"] = (value_p - value_m)/(2*dv)

                    # perturb date and get theta
                    dt = self.daycounter.year_fraction(self.today - 1, self.today + 1)
                    self.settings.evaluation_date = self.today - 1
                    value_m = option.npv
                    self.settings.evaluation_date = self.today + 1
                    value_p = option.npv
                    self.settings.evaluation_date = self.today
                    expected["theta"] = (value_p - value_m)/dt

                    # compare
                    for greek, calcl in calculated.items():
                        expct = expected[greek]
                        tol = tolerance[greek]
                        error = relative_error(expct, calcl, u)
                        self.assertTrue(error < tol)
