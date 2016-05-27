from quantlib.time.api import Date, June
from quantlib.quotes import SimpleQuote

tradedate = Date(13, June, 2011)
deposits = {'1m': 0.00445,
            '2m': 0.00949,
            '3m': 0.01234,
            '6m': 0.01776,
            '9m':0.01935,
            '1y':0.02084}
swaps = {'2y': 0.0165,
         '3y': 0.02018,
         '4y': 0.02303,
         '5y': 0.02525,
         '6y': 0.02696,
         '7y': 0.02825,
         '8y': 0.02931,
         '9y': 0.03017,
         '10y': 0.03092,
         '11y': 0.03160,
         '12y': 0.03231,
         '15y': 0.03367,
         '20y': 0.03419,
         '25y': 0.03411,
         '30y': 0.03412}

m = libor_market('EUR:1Y', calendar='WO')
m.fixed_leg_convention = 'ModifiedFollowing'
quotes = [('DEP', t, SimpleQuote(v)) for t, v in deposits]
quotes += [('SWAP', t, SimpleQuote(v)) for t, v in swaps]
m.set_quotes(tradedate)
ts = m.bootstrap_term_structure()
