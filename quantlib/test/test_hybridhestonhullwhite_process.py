from __future__ import division
from __future__ import print_function

from .unittest_tools import unittest

import numpy as np

from quantlib.settings import Settings

from quantlib.instruments.option import (
    EuropeanExercise)

from quantlib.instruments.payoffs import PAYOFF_TO_STR

from quantlib.models.shortrate.onefactormodels.hullwhite import HullWhite

from quantlib.instruments.option import VanillaOption

from quantlib.time.api import (today, Years, Actual365Fixed,
                               Period, May, Date,
                               NullCalendar)

from quantlib.processes.api import (BlackScholesMertonProcess,
                                    HestonProcess,
                                    HullWhiteProcess)

from quantlib.models.equity.heston_model import (
    HestonModel)

from quantlib.termstructures.yields.api import ZeroCurve, FlatForward
from quantlib.termstructures.volatility.api import BlackConstantVol

from quantlib.pricingengines.api import (
    AnalyticEuropeanEngine,
    AnalyticBSMHullWhiteEngine,
    AnalyticHestonEngine,
    AnalyticHestonHullWhiteEngine,
    FdHestonHullWhiteVanillaEngine)

from quantlib.quotes import SimpleQuote

from quantlib.instruments.payoffs import (
    PlainVanillaPayoff, Put, Call)

from quantlib.methods.finitedifferences.solvers.fdmbackwardsolver import FdmSchemeDesc

def flat_rate(today, forward, daycounter):
    return FlatForward(
        reference_date=today,
        forward=SimpleQuote(forward),
        daycounter=daycounter
    )


class HybridHestonHullWhiteProcessTestCase(unittest.TestCase):

    def setUp(self):

        self.settings = Settings()

        self.calendar = NullCalendar()

        self.todays_date = Date(15, May, 1998)
        self.settlement_date = Date(17, May, 1998)

        self.settings.evaluation_date = self.todays_date

        # options parameters
        self.dividend_yield = 0.00
        self.risk_free_rate = 0.06
        self.volatility = 0.25
        self.spot = SimpleQuote(100)
        self.maturity = Date(17, May, 1999)
        self.daycounter = Actual365Fixed()
        self.tol = 1e-2

        # bootstrap the yield/dividend/vol curves
        dates = [self.settlement_date] + \
                [self.settlement_date + Period(i + 1, Years)
                 for i in range(40)]
        rates = [0.01] + \
            [0.01 + 0.0002 * np.exp(np.sin(i / 4.0)) for i in range(40)]
        divRates = [0.02] + \
                   [0.02 + 0.0001 * np.exp(np.sin(i / 5.0)) for i in range(40)]

        self.r_ts = ZeroCurve(dates, rates, self.daycounter)
        self.q_ts = ZeroCurve(dates, divRates, self.daycounter)

        self.vol_ts = BlackConstantVol(
            self.settlement_date,
            self.calendar,
            self.volatility,
            self.daycounter
        )

        self.black_scholes_merton_process = BlackScholesMertonProcess(
            self.spot,
            self.q_ts,
            self.r_ts,
            self.vol_ts
        )

        self.dates = dates

    def test_bsm_hw(self):
        print("Testing European option pricing for a BSM process" +
              " with one-factor Hull-White model...")

        dc = Actual365Fixed()
        todays_date = today()
        maturity_date = todays_date + Period(20, Years)

        settings = Settings()
        settings.evaluation_date = todays_date

        spot = SimpleQuote(100)

        q_ts = flat_rate(todays_date, 0.04, dc)
        r_ts = flat_rate(todays_date, 0.0525, dc)
        vol_ts = BlackConstantVol(todays_date, NullCalendar(), 0.25, dc)

        hullWhiteModel = HullWhite(r_ts, 0.00883, 0.00526)

        bsm_process = BlackScholesMertonProcess(spot, q_ts,
                                                r_ts, vol_ts)

        exercise = EuropeanExercise(maturity_date)

        fwd = spot.value * q_ts.discount(maturity_date) / \
            r_ts.discount(maturity_date)

        payoff = PlainVanillaPayoff(Call, fwd)

        option = VanillaOption(payoff, exercise)

        tol = 1e-8
        corr = [-0.75, -0.25, 0.0, 0.25, 0.75]
        expectedVol = [0.217064577, 0.243995801, 0.256402830,
                       0.268236596, 0.290461343]

        for c, v in zip(corr, expectedVol):
            bsm_hw_engine = AnalyticBSMHullWhiteEngine(c, bsm_process,
                                                       hullWhiteModel)

            option = VanillaOption(payoff, exercise)
            option.set_pricing_engine(bsm_hw_engine)
            npv = option.npv

            compVolTS = BlackConstantVol(todays_date, NullCalendar(),
                                         v, dc)

            bs_process = BlackScholesMertonProcess(spot, q_ts,
                                                   r_ts, compVolTS)
            bsEngine = AnalyticEuropeanEngine(bs_process)

            comp = VanillaOption(payoff, exercise)
            comp.set_pricing_engine(bsEngine)

            impliedVol = comp.implied_volatility(npv, bs_process,
                                                 1e-10, 500,
                                                 min_vol=0.1,
                                                 max_vol=0.4)

            if (abs(impliedVol - v) > tol):
                print("Failed to reproduce implied volatility cor: %f" % c)
                print("calculated: %f" % impliedVol)
                print("expected  : %f" % v)

            if abs((comp.npv - npv) / npv) > tol:
                print("Failed to reproduce NPV")
                print("calculated: %f" % comp.npv)
                print("expected  : %f" % npv)

            self.assertAlmostEqual(impliedVol, v, delta=tol)
            self.assertAlmostEqual(comp.npv / npv, 1, delta=tol)

    def test_compare_bsm_bsmhw_hestonhw(self):

        dc = Actual365Fixed()

        todays_date = today()
        settings = Settings()
        settings.evaluation_date = todays_date
        tol = 1.e-2

        spot = SimpleQuote(100)

        dates = [todays_date + Period(i, Years) for i in range(40)]

        rates = [0.01 + 0.0002 * np.exp(np.sin(i / 4.0)) for i in range(40)]
        divRates = [0.02 + 0.0001 * np.exp(np.sin(i / 5.0)) for i in range(40)]

        s0 = SimpleQuote(100)

        r_ts = ZeroCurve(dates, rates, dc)
        q_ts = ZeroCurve(dates, divRates, dc)

        vol = SimpleQuote(0.25)
        vol_ts = BlackConstantVol(
            todays_date,
            NullCalendar(),
            vol.value, dc)

        bsm_process = BlackScholesMertonProcess(
            spot, q_ts, r_ts, vol_ts)

        payoff = PlainVanillaPayoff(Call, 100)
        exercise = EuropeanExercise(dates[1])

        option = VanillaOption(payoff, exercise)

        analytic_european_engine = AnalyticEuropeanEngine(bsm_process)

        option.set_pricing_engine(analytic_european_engine)
        npv_bsm = option.npv

        variance = vol.value * vol.value
        hestonProcess = HestonProcess(
            risk_free_rate_ts=r_ts,
            dividend_ts=q_ts,
            s0=s0,
            v0=variance,
            kappa=5.0,
            theta=variance,
            sigma=1e-4,
            rho=0.0)

        hestonModel = HestonModel(hestonProcess)

        hullWhiteModel = HullWhite(r_ts, a=0.01, sigma=0.01)

        bsmhwEngine = AnalyticBSMHullWhiteEngine(
            0.0, bsm_process, hullWhiteModel)

        hestonHwEngine = AnalyticHestonHullWhiteEngine(
            hestonModel, hullWhiteModel, 128)

        hestonEngine = AnalyticHestonEngine(hestonModel, 144)
        option.set_pricing_engine(hestonEngine)

        npv_heston = option.npv

        option.set_pricing_engine(bsmhwEngine)
        npv_bsmhw = option.npv

        option.set_pricing_engine(hestonHwEngine)
        npv_hestonhw = option.npv

        print("calculated with BSM: %f" % npv_bsm)
        print("BSM-HW: %f" % npv_bsmhw)
        print("Heston: %f" % npv_heston)
        print("Heston-HW: %f" % npv_hestonhw)

        self.assertAlmostEqual(npv_bsm, npv_bsmhw, delta=tol)
        self.assertAlmostEqual(npv_bsm, npv_hestonhw, delta=tol)

    def test_compare_BsmHW_HestonHW(self):
        """
        From Quantlib test suite
        """

        print("Comparing European option pricing for a BSM " +
              "process with one-factor Hull-White model...")

        dc = Actual365Fixed()

        todays_date = today()
        settings = Settings()
        settings.evaluation_date = todays_date
        tol = 1.e-2

        spot = SimpleQuote(100)

        dates = [todays_date + Period(i, Years) for i in range(40)]

        rates = [0.01 + 0.0002 * np.exp(np.sin(i / 4.0)) for i in range(40)]
        divRates = [0.02 + 0.0001 * np.exp(np.sin(i / 5.0)) for i in range(40)]

        s0 = SimpleQuote(100)

        r_ts = ZeroCurve(dates, rates, dc)
        q_ts = ZeroCurve(dates, divRates, dc)

        vol = SimpleQuote(0.25)
        vol_ts = BlackConstantVol(
            todays_date,
            NullCalendar(),
            vol.value, dc)

        bsm_process = BlackScholesMertonProcess(
            spot, q_ts, r_ts, vol_ts)

        variance = vol.value * vol.value
        hestonProcess = HestonProcess(
            risk_free_rate_ts=r_ts,
            dividend_ts=q_ts,
            s0=s0,
            v0=variance,
            kappa=5.0,
            theta=variance,
            sigma=1e-4,
            rho=0.0)

        hestonModel = HestonModel(hestonProcess)

        hullWhiteModel = HullWhite(r_ts, a=0.01, sigma=0.01)

        bsmhwEngine = AnalyticBSMHullWhiteEngine(
            0.0, bsm_process, hullWhiteModel)

        hestonHwEngine = AnalyticHestonHullWhiteEngine(
            hestonModel, hullWhiteModel, 128)

        tol = 1e-5
        strikes = [0.25, 0.5, 0.75, 0.8, 0.9,
                   1.0, 1.1, 1.2, 1.5, 2.0, 4.0]
        maturities = [1, 2, 3, 5, 10, 15, 20, 25, 30]
        types = [Put, Call]

        for type in types:
            for strike in strikes:
                for maturity in maturities:
                    maturity_date = todays_date + Period(maturity, Years)

                    exercise = EuropeanExercise(maturity_date)

                    fwd = strike * s0.value * \
                        q_ts.discount(maturity_date) / \
                        r_ts.discount(maturity_date)

                    payoff = PlainVanillaPayoff(type, fwd)

                    option = VanillaOption(payoff, exercise)

                    option.set_pricing_engine(bsmhwEngine)
                    calculated = option.npv

                    option.set_pricing_engine(hestonHwEngine)
                    expected = option.npv

                    if ((np.abs(expected - calculated) > calculated * tol) and
                       (np.abs(expected - calculated) > tol)):

                        cp = PAYOFF_TO_STR[type]
                        print("Failed to reproduce npv")
                        print("strike    : %f" % strike)
                        print("maturity  : %d" % maturity)
                        print("type      : %s" % cp)

                    self.assertAlmostEqual(expected, calculated,
                                            delta=tol)

    def test_zanette(self):
        """
        From paper by A. Zanette et al.
        """

        dc = Actual365Fixed()

        todays_date = today()
        settings = Settings()
        settings.evaluation_date = todays_date

        # constant yield and div curves

        dates = [todays_date + Period(i, Years) for i in range(3)]
        rates = [0.04 for i in range(3)]
        divRates = [0.03 for i in range(3)]
        r_ts = ZeroCurve(dates, rates, dc)
        q_ts = ZeroCurve(dates, divRates, dc)

        s0 = SimpleQuote(100)

        # Heston model

        v0 = .1
        kappa_v = 2
        theta_v = 0.1
        sigma_v = 0.3
        rho_sv = -0.5

        hestonProcess = HestonProcess(
            risk_free_rate_ts=r_ts,
            dividend_ts=q_ts,
            s0=s0,
            v0=v0,
            kappa=kappa_v,
            theta=theta_v,
            sigma=sigma_v,
            rho=rho_sv)

        hestonModel = HestonModel(hestonProcess)

        # Hull-White

        kappa_r = 1
        sigma_r = .2

        hullWhiteProcess = HullWhiteProcess(r_ts, a=kappa_r, sigma=sigma_r)

        strike = 100
        maturity = 1
        type = Call

        maturity_date = todays_date + Period(maturity, Years)

        exercise = EuropeanExercise(maturity_date)

        payoff = PlainVanillaPayoff(type, strike)

        option = VanillaOption(payoff, exercise)

        def price_cal(rho, tGrid):
            fd_hestonHwEngine = FdHestonHullWhiteVanillaEngine(
                hestonModel,
                hullWhiteProcess,
                rho,
                tGrid, 100, 40, 20, 0, True, FdmSchemeDesc.Hundsdorfer())
            option.set_pricing_engine(fd_hestonHwEngine)
            return option.npv

        calc_price = []
        for rho in [-0.5, 0, .5]:
            for tGrid in [50, 100, 150, 200]:
                tmp = price_cal(rho, tGrid)
                print("rho (S,r): %f Ns: %d Price: %f" %
                      (rho, tGrid, tmp))
                calc_price.append(tmp)

        expected_price = [11.38, ] * 4 + [12.79, ] * 4 + [14.06, ] * 4

        np.testing.assert_almost_equal(calc_price, expected_price, 2)
