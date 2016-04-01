from .unittest_tools import unittest

import numpy as np

from quantlib.math.hestonhwcorrelationconstraint import (
    HestonHullWhiteCorrelationConstraint)

from quantlib.time import (
    Period, Months, March, Date,
    Actual365Fixed, TARGET
)

from quantlib.settings import Settings

from quantlib.math.optimization import LevenbergMarquardt, EndCriteria

from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields import FlatForward

from quantlib.models import PriceError
from quantlib.models.equity import HestonModelHelper, HestonModel

from quantlib.processes import HestonProcess, HullWhiteProcess

from quantlib.pricingengines import (
    AnalyticHestonEngine,
    FdHestonHullWhiteVanillaEngine)

from quantlib.methods.finitedifferences.solvers.fdmbackwardsolver import (
    FdmSchemeDesc)


def flat_rate(today, forward, daycounter):
    return FlatForward(
        reference_date=today,
        forward=SimpleQuote(forward),
        daycounter=daycounter
    )


class TestHHWCalibration(unittest.TestCase):

    def test_heston_hw_calibration(self):
        """
        From Quantlib test suite
        """

        print("Testing Heston Hull-White calibration...")

        ## Calibration of a hybrid Heston-Hull-White model using
        ## the finite difference HestonHullWhite pricing engine
        ## Input surface is based on a Heston-Hull-White model with
        ## Hull-White: a = 0.00883, \sigma = 0.00631
        ## Heston    : \nu = 0.12, \kappa = 2.0,
        ##             \theta = 0.09, \sigma = 0.5, \rho=-0.75
        ## Equity Short rate correlation: -0.5

        dc = Actual365Fixed()
        calendar = TARGET()
        todays_date = Date(28, March, 2004)
        settings = Settings()
        settings.evaluation_date = todays_date

        r_ts = flat_rate(todays_date, 0.05, dc)

        ## assuming, that the Hull-White process is already calibrated
        ## on a given set of pure interest rate calibration instruments.

        hw_process = HullWhiteProcess(r_ts, a=0.00883, sigma=0.00631)

        q_ts = flat_rate(todays_date, 0.02, dc)
        s0 = SimpleQuote(100.0)

        # vol surface

        strikes    = [50, 75, 90, 100, 110, 125, 150, 200]
        maturities = [1 / 12., 3 / 12., 0.5, 1.0, 2.0, 3.0, 5.0, 7.5, 10]

        vol = [
        0.482627,0.407617,0.366682,0.340110,0.314266,0.280241,0.252471,0.325552,
        0.464811,0.393336,0.354664,0.329758,0.305668,0.273563,0.244024,0.244886,
        0.441864,0.375618,0.340464,0.318249,0.297127,0.268839,0.237972,0.225553,
        0.407506,0.351125,0.322571,0.305173,0.289034,0.267361,0.239315,0.213761,
        0.366761,0.326166,0.306764,0.295279,0.284765,0.270592,0.250702,0.222928,
        0.345671,0.314748,0.300259,0.291744,0.283971,0.273475,0.258503,0.235683,
        0.324512,0.303631,0.293981,0.288338,0.283193,0.276248,0.266271,0.250506,
        0.311278,0.296340,0.289481,0.285482,0.281840,0.276924,0.269856,0.258609,
        0.303219,0.291534,0.286187,0.283073,0.280239,0.276414,0.270926,0.262173]

        start_v0    = 0.2 * 0.2
        start_theta = start_v0
        start_kappa = 0.5
        start_sigma = 0.25
        start_rho   = -0.5

        equityShortRateCorr = -0.5

        corrConstraint = HestonHullWhiteCorrelationConstraint(
            equityShortRateCorr)

        heston_process = HestonProcess(r_ts, q_ts, s0, start_v0, start_kappa,
                                       start_theta, start_sigma, start_rho)

        h_model = HestonModel(heston_process)
        h_engine = AnalyticHestonEngine(h_model)

        options = []

        # first calibrate a heston model to get good initial
        # parameters

        for i in range(len(maturities)):
            maturity = Period(int(maturities[i] * 12.0 + 0.5), Months)

            for j, s in enumerate(strikes):

                v = SimpleQuote(vol[i * len(strikes) + j])

                helper = HestonModelHelper(maturity, calendar, s0.value,
                                           s, v, r_ts, q_ts,
                                           PriceError)

                helper.set_pricing_engine(h_engine)

                options.append(helper)

        om = LevenbergMarquardt(1e-6, 1e-8, 1e-8)

        # Heston model
        h_model.calibrate(options, om,
                          EndCriteria(400, 40, 1.0e-8,
                                      1.0e-4, 1.0e-8))

        print("Heston calibration")
        print("v0: %f" % h_model.v0)
        print("theta: %f" % h_model.theta)
        print("kappa: %f" % h_model.kappa)
        print("sigma: %f" % h_model.sigma)
        print("rho: %f" % h_model.rho)

        h_process_2 = HestonProcess(r_ts, q_ts, s0, h_model.v0,
                                    h_model.kappa,
                                    h_model.theta,
                                    h_model.sigma,
                                    h_model.rho)

        hhw_model = HestonModel(h_process_2)

        options = []
        for i in range(len(maturities)):

            tGrid = np.max((10.0, maturities[i] * 10.0))
            hhw_engine = FdHestonHullWhiteVanillaEngine(
                hhw_model, hw_process,
                equityShortRateCorr,
                tGrid, 61, 13, 9, 0, True, FdmSchemeDesc.Hundsdorfer())

            hhw_engine.enable_multiple_strikes_caching(strikes)

            maturity = Period(int(maturities[i] * 12.0 + 0.5), Months)

            # multiple strikes engine works best if the first option
            # per maturity has the average strike (because the first
            # option is priced first during the calibration and
            # the first pricing is used to calculate the prices
            # for all strikes

            # list of strikes by distance from moneyness

            indx = np.argsort(np.abs(np.array(strikes) - s0.value))

            for j, tmp in enumerate(indx):
                js = indx[j]
                s = strikes[js]
                v = SimpleQuote(vol[i * len(strikes) + js])
                helper = HestonModelHelper(maturity,
                                           calendar, s0.value,
                                           strikes[js], v, r_ts, q_ts,
                                           PriceError)
                helper.set_pricing_engine(hhw_engine)
                options.append(helper)

        vm = LevenbergMarquardt(1e-6, 1e-2, 1e-2)

        hhw_model.calibrate(options, vm,
                            EndCriteria(400, 40, 1.0e-8, 1.0e-4, 1.0e-8),
                            corrConstraint)

        print("Heston HW calibration with FD engine")
        print("v0: %f" % hhw_model.v0)
        print("theta: %f" % hhw_model.theta)
        print("kappa: %f" % hhw_model.kappa)
        print("sigma: %f" % hhw_model.sigma)
        print("rho: %f" % hhw_model.rho)

        relTol = 0.05
        expected_v0 = 0.12
        expected_kappa = 2.0
        expected_theta = 0.09
        expected_sigma = 0.5
        expected_rho = -0.75

        self.assertAlmostEqual(
            np.abs(hhw_model.v0 - expected_v0) / expected_v0, 0,
            delta=relTol)

        self.assertAlmostEqual(
            np.abs(hhw_model.theta - expected_theta) / expected_theta, 0,
            delta=relTol)

        self.assertAlmostEqual(
            np.abs(hhw_model.kappa - expected_kappa) / expected_kappa, 0,
            delta=relTol)

        self.assertAlmostEqual(
            np.abs(hhw_model.sigma - expected_sigma) / expected_sigma, 0,
            delta=relTol)

        self.assertAlmostEqual(
            np.abs(hhw_model.rho - expected_rho) / expected_rho, 0,
            delta=relTol)
