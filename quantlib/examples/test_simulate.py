# Demo process simulation in QL/Cython

import numpy as np
from quantlib.sim.simulate import simulate
from pylab import plot, show

from quantlib.processes.heston_process import HestonProcess

from quantlib.settings import Settings
from quantlib.time.api import (
    today, Actual360, NullCalendar, Period, Months, Years, Date, July,
    Actual365Fixed, TARGET, Weeks, ActualActual
)
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote

def flat_rate(forward, daycounter):
    return FlatForward(
        quote           = SimpleQuote(forward),
        settlement_days = 0,
        calendar        = NullCalendar(),
        daycounter      = daycounter
    )

DtSettlement = today()

settings = Settings()
settings.evaluation_date = DtSettlement

daycounter = ActualActual()
calendar = NullCalendar()

iRate = .1
iDiv = .04

risk_free_ts = flat_rate(iRate, daycounter)
dividend_ts = flat_rate(iDiv, daycounter)

s0 = SimpleQuote(32.0)

# Heston model

v0 = 0.05
kappa = 5.0;
theta = 0.05;
sigma = 1.0e-4;
rho = -0.5;

ph = HestonProcess(risk_free_ts, dividend_ts, s0, v0,
                       kappa, theta, sigma, rho)

print(ph)

# simulate and plot Heston paths
nbPaths = 4
nbSteps = 100
horizon = 1
seed = 12345
res = simulate(ph, nbPaths, nbSteps, horizon, seed)

t = res[0,:]
plot(t, res[1,:], t, res[2,:], t, res[3,:], t, res[4,:])
show()


