# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# Heston Process Simulation
# =========================
# 
# This notebook demonstrates the simulation of a Heston model. The asset price $S_t$ is governed by the process:
# 
# $$
# \frac{dS_t}{S_t} = \mu dt + \sqrt{\nu_t} dW_t^s
# $$
# 
# where the variance $\nu_t$ is a CIR process: 
# 
# $$
# d \nu_t = \kappa (\theta - \nu_t) dt + \eta \sqrt{\nu_t} dW_t^{\nu}
# $$
# 
# $dW_t^s$ and $dW_t^{\nu}$ are Wiener processes with correlation $\rho$.
# 
# 
# 

# <codecell>

from quantlib.processes.heston_process import HestonProcess
from quantlib.models.equity.heston_model import HestonModel
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.time.api import today, NullCalendar, ActualActual

from quantlib.processes.heston_process import (
        PARTIALTRUNCATION,
        FULLTRUNCATION,
        REFLECTION,
        NONCENTRALCHISQUAREVARIANCE,
        QUADRATICEXPONENTIAL,
        QUADRATICEXPONENTIALMARTINGALE)

# <markdowncell>

# The Heston Process
# ------------------

# <codecell>


def flat_rate(forward, daycounter):
    return FlatForward(
        forward           = SimpleQuote(forward),
        settlement_days = 0,
        calendar        = NullCalendar(),
        daycounter      = daycounter
    )

settings = Settings.instance()
settlement_date = today()
settings.evaluation_date = settlement_date

daycounter = ActualActual()
calendar = NullCalendar()

interest_rate = .1
dividend_yield = .04

risk_free_ts = flat_rate(interest_rate, daycounter)
dividend_ts = flat_rate(dividend_yield, daycounter)

s0 = SimpleQuote(100.0)

# Heston model

v0 = 0.05
kappa = 5.0;
theta = 0.05;
sigma = 1.0e-4;
rho = -0.5;
discretization = QUADRATICEXPONENTIALMARTINGALE


process = HestonProcess(risk_free_ts, dividend_ts, s0, v0,
                       kappa, theta, sigma, rho, discretization)

# <markdowncell>

# The simulation
# --------------
# 
# The *simulate* function is not part of Quantlib. It has been added to the pyQL interface (see folder quantlib/sim). This illustrates how to crerate extensions to Quantlib and expose them to python.

# <codecell>

import pylab as pl
from quantlib.sim.simulate import simulateHeston

# simulate and plot Heston paths
paths = 2
steps = 100
horizon = 2
seed = 12345

model = HestonModel(process)

res = simulateHeston(model, paths, steps, horizon,
                     seed, antithetic=True)

time = res[0,:]
simulations = res[1:, :].T
pl.plot(time, simulations)
pl.xlabel('Time')
pl.ylabel('Stock Price')
pl.title('Heston Process Simulation')
pl.show()


