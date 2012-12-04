""" Simple example pricing a European option 
using a Black&Scholes Merton process."""

import numpy as np

from quantlib.instruments.option import Call, EuropeanExercise
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import VanillaOption
from quantlib.pricingengines.vanilla import AnalyticEuropeanEngine
from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.time.api import TARGET, Actual365Fixed, today
from quantlib.termstructures.yields.api import FlatForward
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure \
    import BlackConstantVol


settings = Settings.instance()
calendar = TARGET()

todays_date = today()
settlement_date = todays_date + 2

settings.evaluation_date = todays_date

# options parameters
option_type = Call
strike = 100
dividend_yield = 0.00
risk_free_rate = 0.06
daycounter = Actual365Fixed()
u_array = np.linspace(30, 200, num=50)

# bootstrap the yield/dividend/vol curves
flat_term_structure = FlatForward(
    reference_date=settlement_date,
    forward=risk_free_rate,
    daycounter=daycounter
)

flat_dividend_ts = FlatForward(
    reference_date=settlement_date,
    forward=dividend_yield,
    daycounter=daycounter
)

payoff = PlainVanillaPayoff(option_type, strike)
method = 'Black-Scholes'


def bs_price(maturity, vol):

    european_exercise = EuropeanExercise(maturity)
    european_option = VanillaOption(payoff, european_exercise)

    flat_vol_ts = BlackConstantVol(
    settlement_date, calendar, vol, daycounter)

    def bs_price_sub(u):
        uH = SimpleQuote(u)

        black_scholes_merton_process = BlackScholesMertonProcess(
        uH, flat_dividend_ts, flat_term_structure, flat_vol_ts)

        analytic_european_engine = \
        AnalyticEuropeanEngine(black_scholes_merton_process)

        european_option.set_pricing_engine(analytic_european_engine)

        return european_option.net_present_value

    return [bs_price_sub(u) for u in u_array]

import matplotlib.pyplot as plt

@interact
def plot_bs(maturity=(1,(1,5)), vol=(10,(10,100))):
    mat = settlement_date + 365*maturity
    p = bs_price(mat, vol)
    plt.plot(u_array,p)
    plt.grid(True)
