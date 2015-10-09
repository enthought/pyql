from __future__ import division
from __future__ import print_function

from .unittest_tools import unittest

import numpy as np

from quantlib.instruments.option import (
    EuropeanExercise)

from quantlib.instruments.payoffs import PAYOFF_TO_STR

from quantlib.models.shortrate.onefactormodels.hullwhite import HullWhite
from quantlib.settings import Settings

from quantlib.instruments.option import VanillaOption
from quantlib.time.api import (today, Years, Actual365Fixed, TARGET,
                               Period, March, May, Date, Months, NullCalendar)
from quantlib.processes.api import (BlackScholesMertonProcess, HestonProcess)

from quantlib.models.equity.heston_model import (
    HestonModelHelper, HestonModel)

from quantlib.models.calibration_helper import (
    RelativePriceError, PriceError)

from quantlib.math.hestonhwcorrelationconstraint import (
    HestonHullWhiteCorrelationConstraint)

from quantlib.termstructures.yields.api import ZeroCurve, FlatForward
from quantlib.termstructures.volatility.api import BlackConstantVol

from quantlib.math.optimization import LevenbergMarquardt, EndCriteria

from quantlib.pricingengines.api import (
    AnalyticEuropeanEngine,
    AnalyticBSMHullWhiteEngine,
    AnalyticHestonEngine,
    AnalyticHestonHullWhiteEngine)

from quantlib.quotes import SimpleQuote

from quantlib.instruments.payoffs import (
    PlainVanillaPayoff, Put, Call)


def flat_rate(today, forward, daycounter):
    return FlatForward(
        reference_date=today,
        forward=SimpleQuote(forward),
        daycounter=daycounter
    )


def flat_vol(volatility, daycounter):
    return BlackVolTermStructure(volatility, daycounter)


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

            self.assertAlmostEquals(impliedVol, v, delta=tol)
            self.assertAlmostEquals(comp.npv / npv, 1, delta=tol)

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

        self.assertAlmostEquals(npv_bsm, npv_bsmhw, delta=tol)
        self.assertAlmostEquals(npv_bsm, npv_hestonhw, delta=tol)

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

                    self.assertAlmostEquals(expected, calculated,
                                            delta=tol)

    def test_heston_hw_calibration(self):
        """
        From Quantlib test suite
        """

        print("Testing the Heston Hull-White calibration...")

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

        r_ts = flat_rate(0.05, dc)

        ## assuming, that the Hull-White process is already calibrated
        ## on a given set of pure interest rate calibration instruments.

        hw_process = HullWhiteProcess(r_ts, 0.00883, 0.00631)
        hullWhiteModel = HullWhite(r_ts, hw_process.a, hw_process.sigma)

        q_ts = flat_rate(0.02, dc)
        s0 = SimpleQuote(100.0)

        start_v0    = 0.2 * 0.2
        start_theta = start_v0
        start_kappa = 0.5
        start_sigma = 0.25
        start_rho   = -0.5

        heston_process = HestonProcess(r_ts, q_ts, s0, start_v0, start_kappa,
                                       start_theta, start_sigma, start_rho)

        analyticHestonModel = HestonModel(heston_process)

        analyticHestonEngine = AnalyticHestonEngine(analyticHestonModel, 164)
        fdmHestonModel = HestonModel(heston_process)

        equityShortRateCorr = -0.5

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

        options = []

        for i in range(len(maturities)):
            maturity = Period(int(maturities[i] * 12.0 + 0.5), Months)
            exercise = EuropeanExercise(todays_date + maturity)

            for j in range(len(strikes)):
                payoff = PlainVanillaPayoff(Call, strikes[j])

                v = SimpleQuote(vol[i * len(strikes) + j])
                helper = HestonModelHelper(maturity, calendar, s0.value,
                                           strikes[j], v, r_ts, q_ts,
                                           PriceError)

                marketValue = helper.market_value

                options.append(helper)

                ## Improve the quality of the starting point
                ## for the full Heston-Hull-White calibration

                bs_process = BlackScholesMertonProcess(
                    s0, q_ts, r_ts,
                    flat_vol(v.value, dc))

                dummyOption = VanillaOption(payoff, exercise)

                bs_hw_engine = AnalyticBSMHullWhiteEngine(
                    equityShortRateCorr,
                    bs_process, hullWhiteModel)

                vt = detail::ImpliedVolatilityHelper::calculate(
                ##     dummyOption, *bshwEngine, *volQuote,
                ##     marketValue, 1e-8, 100, 0.0001, 10);

                ## v.linkTo(boost::shared_ptr<Quote>(new SimpleQuote(vt)));

                ## options.back()->setPricingEngine(
                ##     boost::shared_ptr<PricingEngine>(analyticHestonEngine));

        equityShortRateCorr = -0.5
        corrConstraint = HestonHullWhiteCorrelationConstraint(
            equityShortRateCorr)

        om = LevenbergMarquardt(1e-6, 1e-8, 1e-8)

        analyticHestonModel.calibrate(options, om,
                                      EndCriteria(400, 40, 1.0e-8,
                                                  1.0e-4, 1.0e-8),
                                      corrConstraint)


##     options = []

##     fdmHestonModel.set_params(analyticHestonModel.params)

##     for i in range(length(maturities)):
##         tGrid = np.max(10.0, maturities[i]*10.0)
##         engine = FdHestonHullWhiteVanillaEngine(fdmHestonModel, hwProcess, 
##                                                equityShortRateCorr, 
##                                                tGrid, 61, 13, 9, 0, true)

##         engine.enableMultipleStrikesCaching(
##                      std::vector<Real>(strikes, strikes + LENGTH(strikes)));
        
##         const Period maturity((int)(maturities[i]*12.0+0.5), Months);
        
##         for (Size j=0; j < LENGTH(strikes); ++j) {
##             // multiple strikes engine works best if the first option
##             // per maturity has the average strike (because the first option
##             // is priced first during the calibration and the first pricing
##             // is used to calculate the prices for all strikes
##             const Size js = (j + (LENGTH(strikes)-1)/2) % LENGTH(strikes);
 
##             boost::shared_ptr<StrikedTypePayoff> payoff(
##                              new PlainVanillaPayoff(Option::Call, strikes[js]));
##             Handle<Quote> v(boost::shared_ptr<Quote>(
##                                    new SimpleQuote(vol[i*LENGTH(strikes)+js])));
##             options.push_back(boost::shared_ptr<CalibrationHelper>(
##                 new HestonModelHelper(maturity, calendar, s0->value(), 
##                                       strikes[js], v, rTS, qTS,
##                                       CalibrationHelper::PriceError)));
            
##             options.back()->setPricingEngine(engine);
##         }
##     }    

##     LevenbergMarquardt vm(1e-6, 1e-2, 1e-2);
##     fdmHestonModel->calibrate(options, vm, 
##                               EndCriteria(400, 40, 1.0e-8, 1.0e-4, 1.0e-8),
##                               corrConstraint);
    
##     const Real relTol = 0.01;
##     const Real expected_v0    =  0.12;
##     const Real expected_kappa =  2.0;
##     const Real expected_theta =  0.09;
##     const Real expected_sigma =  0.5;
##     const Real expected_rho   = -0.75;
    
##     if (std::fabs(fdmHestonModel->v0() - expected_v0)/expected_v0 > relTol) {
##          BOOST_ERROR("Failed to reproduce Heston-Hull-White model"
##                  << "\n   v0 calculated: " << fdmHestonModel->v0()
##                  << "\n   v0 expected  : " << expected_v0
##                  << "\n   relatove tol : " << relTol);
##     }
##     if (std::fabs(fdmHestonModel->theta() - expected_theta)/expected_theta 
##                                                                     > relTol) {
##          BOOST_ERROR("Failed to reproduce Heston-Hull-White model"
##                  << "\n   theta calculated: " << fdmHestonModel->theta()
##                  << "\n   theta expected  : " << expected_theta
##                  << "\n   relatove tol    : " << relTol);
##     }
##     if (std::fabs(fdmHestonModel->kappa() - expected_kappa)/expected_kappa 
##                                                                     > relTol) {
##         BOOST_ERROR("Failed to reproduce Heston-Hull-White model"
##                 << "\n   kappa calculated: " << fdmHestonModel->kappa()
##                 << "\n   kappa expected  : " << expected_kappa
##                 << "\n   relatove tol    : " << relTol);
##     }
##     if (std::fabs(fdmHestonModel->sigma() - expected_sigma)/expected_sigma 
##                                                                     > relTol) {
##        BOOST_ERROR("Failed to reproduce Heston-Hull-White model"
##                << "\n   sigma calculated: " << fdmHestonModel->sigma()
##                << "\n   sigma expected  : " << expected_sigma
##                << "\n   relatove tol    : " << relTol);
##     }
##     if (std::fabs(fdmHestonModel->rho() - expected_rho)/expected_rho > relTol) {
##          BOOST_ERROR("Failed to reproduce Heston-Hull-White model"
##                  << "\n   rho calculated: " << fdmHestonModel->rho()
##                  << "\n   rho expected  : " << expected_rho
##                  << "\n   relatove tol  : " << relTol);
##     }
## }
