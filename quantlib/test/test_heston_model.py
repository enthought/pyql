from __future__ import division
from __future__ import print_function
import numpy as np

from .unittest_tools import unittest

from quantlib.instruments.option import EuropeanExercise, VanillaOption, Call, Put
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.models.calibration_helper import ImpliedVolError
from quantlib.models.equity.heston_model import (
    HestonModelHelper, HestonModel
)

from quantlib.processes.heston_process import HestonProcess
from quantlib.processes.bates_process import BatesProcess
from quantlib.models.equity.bates_model import (BatesDetJumpModel)

from quantlib.pricingengines.blackformula import blackFormula
from quantlib.pricingengines.vanilla.vanilla import (
    AnalyticHestonEngine,
    BatesDetJumpEngine)
from quantlib.processes.heston_process import QUADRATICEXPONENTIAL
from quantlib.math.optimization import LevenbergMarquardt, EndCriteria
from quantlib.settings import Settings
from quantlib.time.api import (
    today, Actual360, NullCalendar, Period, Months, Years, Date, July,
    Actual365Fixed, TARGET, Weeks, ActualActual
)
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.zero_curve import ZeroCurve

from quantlib.pricingengines.vanilla.mceuropeanhestonengine import MCEuropeanHestonEngine


def flat_rate(forward, daycounter):
    return FlatForward(
        forward=SimpleQuote(forward),
        settlement_days=0,
        calendar=NullCalendar(),
        daycounter=daycounter
    )


class HestonModelTestCase(unittest.TestCase):
    """Test cases are based on the test-suite/hestonmodel.cpp in QuantLib.

    """

    def setUp(self):

        self.settings = Settings()

    def test_black_calibration(self):

        # calibrate a Heston model to a constant volatility surface without
        # smile. expected result is a vanishing volatility of the volatility.
        # In addition theta and v0 should be equal to the constant variance

        todays_date = today()

        self.settings.evaluation_date = todays_date

        daycounter = Actual360()
        calendar = NullCalendar()

        risk_free_ts = flat_rate(0.04, daycounter)
        dividend_ts = flat_rate(0.50, daycounter)

        option_maturities = [
            Period(1, Months),
            Period(2, Months),
            Period(3, Months),
            Period(6, Months),
            Period(9, Months),
            Period(1, Years),
            Period(2, Years)
        ]

        options = []

        s0 = SimpleQuote(1.0)
        vol = SimpleQuote(0.1)

        volatility = vol.value

        for maturity in option_maturities:
            for moneyness in np.arange(-1.0, 2.0, 1.):
                tau = daycounter.year_fraction(
                    risk_free_ts.reference_date,
                    calendar.advance(
                        risk_free_ts.reference_date,
                        period=maturity)
                )
                forward_price = s0.value * dividend_ts.discount(tau) / \
                                risk_free_ts.discount(tau)
                strike_price = forward_price * np.exp(
                    -moneyness * volatility * np.sqrt(tau)
                )
                options.append(
                    HestonModelHelper(
                        maturity, calendar, s0.value, strike_price, vol,
                        risk_free_ts, dividend_ts
                    )
                )

        for sigma in np.arange(0.1, 0.7, 0.2):
            v0    = 0.01
            kappa = 0.2
            theta = 0.02
            rho   = -0.75

            process = HestonProcess(
                risk_free_ts, dividend_ts, s0, v0, kappa, theta, sigma, rho
            )

            self.assertEqual(v0, process.v0)
            self.assertEqual(kappa, process.kappa)
            self.assertEqual(theta, process.theta)
            self.assertEqual(sigma, process.sigma)
            self.assertEqual(rho, process.rho)
            self.assertEqual(1.0, process.s0.value)

            model = HestonModel(process)
            engine = AnalyticHestonEngine(model, 96)

            for option in options:
                option.set_pricing_engine(engine)

            optimisation_method = LevenbergMarquardt(1e-8, 1e-8, 1e-8)

            end_criteria = EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
            model.calibrate(options, optimisation_method, end_criteria)

            tolerance = 3.0e-3

            self.assertFalse(model.sigma > tolerance)

            self.assertAlmostEqual(
                model.kappa * model.theta,
                model.kappa * volatility ** 2,
                delta=tolerance
            )
            self.assertAlmostEqual(model.v0, volatility ** 2, delta=tolerance)

    def test_DAX_calibration(self):

        # this example is taken from A. Sepp
        # Pricing European-Style Options under Jump Diffusion Processes
        # with Stochstic Volatility: Applications of Fourier Transform
        # http://math.ut.ee/~spartak/papers/stochjumpvols.pdf

        settlement_date = Date(5, July, 2002)

        self.settings.evaluation_date = settlement_date

        daycounter = Actual365Fixed()
        calendar = TARGET()

        t = [13, 41, 75, 165, 256, 345, 524, 703]
        r = [0.0357,0.0349,0.0341,0.0355,0.0359,0.0368,0.0386,0.0401]

        dates = [settlement_date] + [settlement_date + val for val in t]
        rates = [0.0357] + r

        risk_free_ts = ZeroCurve(dates, rates, daycounter)
        dividend_ts = FlatForward(
            settlement_date, forward=0.0, daycounter=daycounter
        )

        v = [
            0.6625,0.4875,0.4204,0.3667,0.3431,0.3267,0.3121,0.3121,
            0.6007,0.4543,0.3967,0.3511,0.3279,0.3154,0.2984,0.2921,
            0.5084,0.4221,0.3718,0.3327,0.3155,0.3027,0.2919,0.2889,
            0.4541,0.3869,0.3492,0.3149,0.2963,0.2926,0.2819,0.2800,
            0.4060,0.3607,0.3330,0.2999,0.2887,0.2811,0.2751,0.2775,
            0.3726,0.3396,0.3108,0.2781,0.2788,0.2722,0.2661,0.2686,
            0.3550,0.3277,0.3012,0.2781,0.2781,0.2661,0.2661,0.2681,
            0.3428,0.3209,0.2958,0.2740,0.2688,0.2627,0.2580,0.2620,
            0.3302,0.3062,0.2799,0.2631,0.2573,0.2533,0.2504,0.2544,
            0.3343,0.2959,0.2705,0.2540,0.2504,0.2464,0.2448,0.2462,
            0.3460,0.2845,0.2624,0.2463,0.2425,0.2385,0.2373,0.2422,
            0.3857,0.2860,0.2578,0.2399,0.2357,0.2327,0.2312,0.2351,
            0.3976,0.2860,0.2607,0.2356,0.2297,0.2268,0.2241,0.2320
        ]

        s0 = SimpleQuote(4468.17)
        strikes = [
            3400, 3600, 3800, 4000, 4200, 4400, 4500, 4600, 4800, 5000, 5200,
            5400, 5600
        ]

        options = []

        for s, strike in enumerate(strikes):
            for m in range(len(t)):
                vol = SimpleQuote(v[s * 8 + m])
                # round to weeks
                maturity = Period((int)((t[m] + 3) / 7.), Weeks)
                options.append(
                    HestonModelHelper(
                        maturity, calendar, s0.value, strike, vol,
                        risk_free_ts, dividend_ts,
                        ImpliedVolError
                    )
                )

        v0    = 0.1
        kappa = 1.0
        theta = 0.1
        sigma = 0.5
        rho   = -0.5

        process = HestonProcess(
            risk_free_ts, dividend_ts, s0, v0, kappa, theta, sigma, rho
        )

        model = HestonModel(process)

        engine = AnalyticHestonEngine(model, 64)

        for option in options:
            option.set_pricing_engine(engine)

        om = LevenbergMarquardt(1e-8, 1e-8, 1e-8)

        model.calibrate(
            options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
        )

        sse = 0
        for i in range(len(strikes) * len(t)):
            diff = options[i].calibration_error() * 100.0
            sse += diff * diff

        expected = 177.2  # see article by A. Sepp.
        self.assertAlmostEqual(expected, sse, delta=1.0)

    def test_analytic_versus_black(self):
        settlement_date = today()
        self.settings.evaluation_date = settlement_date

        daycounter = ActualActual()

        exercise_date = settlement_date + Period(6, Months)

        payoff = PlainVanillaPayoff(Put, 30)

        exercise = EuropeanExercise(exercise_date)

        risk_free_ts = flat_rate(0.1, daycounter)
        dividend_ts = flat_rate(0.04, daycounter)

        s0 = SimpleQuote(32.0)

        v0    = 0.05
        kappa = 5.0
        theta = 0.05
        sigma = 1.0e-4
        rho   = 0.0

        process = HestonProcess(
            risk_free_ts, dividend_ts, s0, v0, kappa, theta, sigma, rho
        )

        option = VanillaOption(payoff, exercise)

        engine = AnalyticHestonEngine(HestonModel(process), 144)

        option.set_pricing_engine(engine)

        calculated = option.net_present_value

        year_fraction = daycounter.year_fraction(
            settlement_date, exercise_date
        )

        forward_price = 32 * np.exp((0.1 - 0.04) * year_fraction)
        expected = blackFormula(
            payoff.type, payoff.strike, forward_price,
            np.sqrt(0.05 * year_fraction)
        ) * np.exp(-0.1 * year_fraction)

        tolerance = 2.0e-7

        self.assertAlmostEqual(
            calculated,
            expected,
            delta=tolerance
        )

    def test_bates_det_jump(self):
        # this looks like a bug in QL:
        # Bates Det Jump model does not have sigma as parameter, yet
        # changing sigma changes the result!

        settlement_date = today()
        self.settings.evaluation_date = settlement_date

        daycounter = ActualActual()

        exercise_date = settlement_date + Period(6, Months)

        payoff = PlainVanillaPayoff(Put, 1290)
        exercise = EuropeanExercise(exercise_date)
        option = VanillaOption(payoff, exercise)

        risk_free_ts = flat_rate(0.02, daycounter)
        dividend_ts = flat_rate(0.04, daycounter)

        spot = 1290

        ival = {'delta': 3.6828677022272715e-06,
        'kappa': 19.02581428347027,
        'kappaLambda': 1.1209758060939223,
        'lambda': 0.06524550732595163,
        'nu': -1.8968106563601956,
        'rho': -0.7480898462264719,
        'sigma': 1.0206363887835108,
        'theta': 0.01965384459461113,
        'thetaLambda': 0.028915397380738218,
        'v0': 0.06566800935242285}

        process = BatesProcess(
        risk_free_ts, dividend_ts, SimpleQuote(spot),
        ival['v0'], ival['kappa'],
        ival['theta'], ival['sigma'], ival['rho'],
        ival['lambda'], ival['nu'], ival['delta'])

        model = BatesDetJumpModel(process,
                ival['kappaLambda'], ival['thetaLambda'])

        engine = BatesDetJumpEngine(model, 64)

        option.set_pricing_engine(engine)

        calc_1 = option.net_present_value

        ival['sigma'] = 1.e-6

        process = BatesProcess(
        risk_free_ts, dividend_ts, SimpleQuote(spot),
        ival['v0'], ival['kappa'],
        ival['theta'], ival['sigma'], ival['rho'],
        ival['lambda'], ival['nu'], ival['delta'])

        model = BatesDetJumpModel(process,
                ival['kappaLambda'], ival['thetaLambda'])
        engine = BatesDetJumpEngine(model, 64)

        option.set_pricing_engine(engine)

        calc_2 = option.net_present_value

        if(abs(calc_1-calc_2) > 1.e-5):
            print('calc 1 %f calc 2 %f' % (calc_1, calc_2))
        self.assertNotEqual(calc_1, calc_2)

    def test_smith(self):
        # test against result published in
        # Journal of Computational Finance Vol. 11/1 Fall 2007
        # An almost exact simulation method for the heston model

        settlement_date = today()
        self.settings.evaluation_date = settlement_date

        daycounter = ActualActual()
        timeToMaturity = 4

        exercise_date = settlement_date + timeToMaturity * 365

        c_payoff = PlainVanillaPayoff(Call, 100)

        exercise = EuropeanExercise(exercise_date)

        risk_free_ts = flat_rate(0., daycounter)
        dividend_ts = flat_rate(0., daycounter)

        s0 = SimpleQuote(100.0)

        v0    = 0.0194
        kappa = 1.0407
        theta = 0.0586
        sigma = 0.5196
        rho   = -.6747

        nb_steps_a = 100
        nb_paths = 20000
        seed = 12347

        process = HestonProcess(
            risk_free_ts, dividend_ts, s0, v0, kappa, theta,
            sigma, rho, QUADRATICEXPONENTIAL)

        model = HestonModel(process)

        option = VanillaOption(c_payoff, exercise)

        engine = AnalyticHestonEngine(model, 144)

        option.set_pricing_engine(engine)

        price_fft  = option.net_present_value

        engine = MCEuropeanHestonEngine(
            process,
            antithetic_variate=True,
            steps_per_year=nb_steps_a,
            required_samples=nb_paths,
            seed=seed)

        option.set_pricing_engine(engine)
        price_mc = option.net_present_value

        expected = 15.1796
        tolerance = .05

        self.assertAlmostEqual(price_fft, expected, delta=tolerance)
        self.assertAlmostEqual(price_mc, expected, delta=tolerance)

if __name__ == '__main__':
    unittest.main()
