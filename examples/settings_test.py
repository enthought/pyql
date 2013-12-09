from __future__ import print_function
# simple example to demonstrate the use of Settings()


from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import FlatForward
from quantlib.time.api import Actual360, Date, NullCalendar, TARGET

calendar = TARGET()
settings = Settings()

date_today      = Date(6,9,2011)
date_payment    = Date(6,10,2011)
settlement_days = 2

settings.evaluation_date = date_today
quote = SimpleQuote(value=0.03)

term_structure = FlatForward(
    settlement_days = settlement_days,
    quote           = quote,
    calendar        = NullCalendar(),
    daycounter      = Actual360()
)

df_1 = term_structure.discount(date_payment)

date_today = Date(19,9,2011)
settings.evaluation_date = date_today

date_payment = Date(19,10,2011)
df_2 = term_structure.discount(date_payment)

# df_1 and df_2 should be identical:
print('rate: %f df_1: %f df_2 %f difference: %f' % (quote.value, df_1, df_2, df_2-df_1))

# the term structure registers a listener on the quote: a change in quote
# triggers a lazy recalculation of the discount factor

quote.value = .05
df_2 = term_structure.discount(date_payment)
print('rate: %f df_2: %f' % (quote.value, df_2))
