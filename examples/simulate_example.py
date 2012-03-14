""" Example of using simulation of a process with PyQL.

"""

from pylab import plot, show

from quantlib.processes.heston_process import HestonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.sim.simulate import simulate
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
kappa = 5.0;
theta = 0.05;
sigma = 1.0e-4;
rho = -0.5;

process = HestonProcess(risk_free_ts, dividend_ts, s0, v0,
                       kappa, theta, sigma, rho)

# simulate and plot Heston paths
paths = 4
steps = 100
horizon = 1
seed = 12345

res = simulate(process, paths, steps, horizon, seed)

time = res[0,:]
simulations = res[1:, :].T
plot(time, simulations)
show()


