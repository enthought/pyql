"""
Option pricing with a hybrid Heston / Hull-White model

Data are from a paper by A. Zanette et al.

"""

from __future__ import division
from __future__ import print_function

import numpy as np

from quantlib.settings import Settings

from quantlib.instruments import (EuropeanExercise, PAYOFF_TO_STR)

from quantlib.models.shortrate.onefactormodels import HullWhite

from quantlib.instruments.option import VanillaOption

from quantlib.time import (today, Years, Actual365Fixed,
                           Period, May, Date,
                           NullCalendar)

from quantlib.processes import (BlackScholesMertonProcess,
                                HestonProcess,
                                HullWhiteProcess)

from quantlib.models.equity import HestonModel

from quantlib.termstructures.yields import ZeroCurve, FlatForward
from quantlib.termstructures.volatility import BlackConstantVol

from quantlib.pricingengines import (
    AnalyticEuropeanEngine,
    AnalyticBSMHullWhiteEngine,
    AnalyticHestonEngine,
    AnalyticHestonHullWhiteEngine,
    FdHestonHullWhiteVanillaEngine)

from quantlib.quotes import SimpleQuote

from quantlib.instruments.payoffs import (
    PlainVanillaPayoff, Put, Call)

from quantlib.methods.finitedifferences.solvers.fdmbackwardsolver \
     import FdmSchemeDesc


def flat_rate(today, forward, daycounter):
    return FlatForward(
        reference_date=today,
        forward=SimpleQuote(forward),
        daycounter=daycounter
    )

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

expected_price = [11.38, ] * 4 + [12.81, ] * 4 + [14.08, ] * 4

