"""
Simulation of stochastic processes with PyQL.

"""

from pylab import plot, show, figure

from quantlib.processes.heston_process import HestonProcess
from quantlib.processes.bates_process import BatesProcess
from quantlib.models.equity.heston_model import HestonModel
from quantlib.models.equity.bates_model import BatesModel
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.sim.simulate import simulateHeston, simulateBates
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.time.api import today, NullCalendar, ActualActual


def flat_rate(forward, daycounter):
    return FlatForward(
        quote           = SimpleQuote(forward),
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

s0 = SimpleQuote(32.0)

# Heston model

v0 = 0.05
kappa = 5.0
theta = 0.05
sigma = 1.0e-4
rho = -0.5

process = HestonProcess(risk_free_ts, dividend_ts, s0, v0,
                       kappa, theta, sigma, rho)


# simulate and plot Heston paths
paths = 200
steps = 200
horizon = 1
seed = 12345

model = HestonModel(process)

res = simulateHeston(model, paths, steps, horizon, seed)

time = res[0, :]
simulations = res[1:, :].T

figure()
plot(time, simulations)
show()

ival = {'v0': v0, 'kappa': 3.7, 'theta': v0,
    'sigma': 1.0, 'rho': -.6, 'lambda': .1,
    'nu':-.5, 'delta': 0.3}

spot = SimpleQuote(1200)

proc_bates = BatesProcess(
    risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
     ival['theta'], ival['sigma'], ival['rho'],
     ival['lambda'], ival['nu'], ival['delta'])

model_bates = BatesModel(proc_bates)

res_bates = simulateBates(model_bates, paths, steps, horizon, seed)

time = res_bates[0, :]
simulations = res_bates[1:, :].T
figure()
plot(time, simulations)
show()
