"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from quantlib.instruments.api import AmericanExercise, VanillaOption, Put
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.pricingengines.api import BaroneAdesiWhaleyApproximationEngine
from quantlib.pricingengines.api import FDAmericanEngine
from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.time.api import Actual365Fixed, Date, May, TARGET
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure \
        import BlackConstantVol
from quantlib.termstructures.yields.api import FlatForward


def main():
    # global data
    todays_date = Date(15, May, 1998)
    Settings.instance().evaluation_date = todays_date
    settlement_date = Date(17, May, 1998)

    risk_free_rate = FlatForward(
        reference_date = settlement_date,
        forward        = 0.06,
        daycounter     = Actual365Fixed()
    )

    # option parameters
    exercise = AmericanExercise(
        earliest_exercise_date = settlement_date,
        latest_exercise_date   = Date(17, May, 1999)
    )
    payoff = PlainVanillaPayoff(Put, 40.0)

    # market data
    underlying = SimpleQuote(36.0)
    volatility = BlackConstantVol(todays_date, TARGET(), 0.20, Actual365Fixed())
    dividend_yield = FlatForward(
        reference_date = settlement_date,
        forward        = 0.00,
        daycounter     = Actual365Fixed()
    )

    # report
    header = '%19s' % 'method' + ' |' + \
            ' |'.join(['%17s' % tag for tag in ['value',
                                                'estimated error',
                                                'actual error' ] ])
    print
    print header
    print '-'*len(header)

    refValue = None
    def report(method, x, dx = None):
        e = '%.4f' % abs(x-refValue)
        x = '%.5f' % x
        if dx:
            dx = '%.4f' % dx
        else:
            dx = 'n/a'
        print '%19s' % method + ' |' + \
            ' |'.join(['%17s' % y for y in [x, dx, e] ])

    # good to go

    process = BlackScholesMertonProcess(
        underlying, dividend_yield, risk_free_rate, volatility
    )

    option = VanillaOption(payoff, exercise)

    refValue = 4.48667344
    report('reference value',refValue)

    # method: analytic

    option.set_pricing_engine(BaroneAdesiWhaleyApproximationEngine(process))
    report('Barone-Adesi-Whaley',option.net_present_value)

    # method: finite differences
    time_steps = 801
    grid_points = 800

    option.set_pricing_engine(FDAmericanEngine('CrankNicolson', process,time_steps,grid_points))
    report('finite differences',option.net_present_value)


    print 'This is work in progress.'
    print 'Some pricing engines are not yet interfaced.'

    return

    option.set_pricing_engine(BjerksundStenslandEngine(process))
    report('Bjerksund-Stensland',option.NPV())

    # method: binomial
    timeSteps = 801

    option.setPricingEngine(BinomialVanillaEngine(process,'jr',timeSteps))
    report('binomial (JR)',option.NPV())

    option.setPricingEngine(BinomialVanillaEngine(process,'crr',timeSteps))
    report('binomial (CRR)',option.NPV())

    option.setPricingEngine(BinomialVanillaEngine(process,'eqp',timeSteps))
    report('binomial (EQP)',option.NPV())

    option.setPricingEngine(BinomialVanillaEngine(process,'trigeorgis',timeSteps))
    report('bin. (Trigeorgis)',option.NPV())

    option.setPricingEngine(BinomialVanillaEngine(process,'tian',timeSteps))
    report('binomial (Tian)',option.NPV())

    option.setPricingEngine(BinomialVanillaEngine(process,'lr',timeSteps))
    report('binomial (LR)',option.NPV())

if __name__ == '__main__':
    main()

