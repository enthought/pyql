""" Simple example pricing a European option 
using a Black&Scholes Merton process."""

from quantlib.instruments.option import Put, EuropeanExercise
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

offset = 366

todays_date = today() - offset
settlement_date = todays_date + 2

settings.evaluation_date = todays_date

# options parameters
option_type = Put
underlying = 36
strike = 40
dividend_yield = 0.00
risk_free_rate = 0.06
volatility = 0.20
maturity = settlement_date + 363
daycounter = Actual365Fixed()

underlyingH = SimpleQuote(underlying)

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

flat_vol_ts = BlackConstantVol(
    settlement_date, calendar, volatility, daycounter
)

black_scholes_merton_process = BlackScholesMertonProcess(
    underlyingH, flat_dividend_ts, flat_term_structure, flat_vol_ts
)

payoff = PlainVanillaPayoff(option_type, strike)

european_exercise = EuropeanExercise(maturity)

european_option = VanillaOption(payoff, european_exercise)


method = 'Black-Scholes'
analytic_european_engine = AnalyticEuropeanEngine(black_scholes_merton_process)

european_option.set_pricing_engine(analytic_european_engine)

print(
    'today: %s settlement: %s maturity: %s' % (
        todays_date, settlement_date, maturity
    )
)
print('NPV: %f\n' % european_option.net_present_value)


### EOF #######################################################################