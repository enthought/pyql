"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

# Heston & Bates Process Simulation
# =================================
# 
# This script demonstrates the simulation of Heston and Bates model.

# Heston process
# ==============

# The asset price $S_t$ is governed by the process:
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

from quantlib.processes.bates_process import BatesProcess
from quantlib.models.equity.bates_model import BatesModel
from quantlib.processes.heston_process import HestonProcess
from quantlib.models.equity.heston_model import HestonModel
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.time.api import today, NullCalendar, ActualActual
from quantlib.util.rates import flat_rate
import pylab as pl
from quantlib.sim.simulate import simulateHeston, simulateBates

# The Heston Process
# ------------------

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
kappa = 5.0
theta = 0.05
sigma = 1.0e-4
rho = -0.5

process = HestonProcess(risk_free_ts, dividend_ts, s0, v0,
                       kappa, theta, sigma, rho)

# The simulation
# --------------
#
# The *simulateHeston* function is not part of Quantlib. It has been added
# to the pyQL interface (see folder quantlib/sim). This illustrates
# how to create extensions to Quantlib and expose them to python.


# simulate and plot Heston paths
paths = 20
steps = 100
horizon = 2
seed = 12345

model = HestonModel(process)

res = simulateHeston(model, paths, steps, horizon, seed)

time = res[0, :]
simulations = res[1:, :].T
pl.figure()
pl.plot(time, simulations)
pl.xlabel('Time')
pl.ylabel('Stock Price')
pl.title('Heston Process Simulation')
pl.show()

# The Bates process
# -----------------

ival = {'v0': v0, 'kappa': 3.7, 'theta': v0,
    'sigma': 1.0, 'rho': -.6, 'lambda': .1,
    'nu': -.5, 'delta': 0.3}

spot = SimpleQuote(1200)

proc_bates = BatesProcess(
    risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
     ival['theta'], ival['sigma'], ival['rho'],
     ival['lambda'], ival['nu'], ival['delta'])

model_bates = BatesModel(proc_bates)

res_bates = simulateBates(model_bates, paths, steps, horizon, seed)

time = res_bates[0, :]
simulations = res_bates[1:, :].T
pl.figure()
pl.plot(time, simulations)
pl.xlabel('Time')
pl.ylabel('Stock Price')
pl.title('Bates Process Simulation')
pl.show()
