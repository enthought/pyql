# simple example to demonstrate the use of Settings()

from quantlib.termstructures.yields.flat_forward import (
    SimpleQuote, FlatForward, YieldTermStructure
)

from quantlib.settings import Settings
from quantlib.time.calendar import TARGET
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.daycounter import Actual360, Actual365Fixed
from quantlib.time.date import today, Days, Date

calendar = TARGET()

dt_today = Date(6,9,2011)
dt_payment = Date(6,10,2011)
settlement_days = 2

Settings().evaluation_date = dt_today 
quote = SimpleQuote()
quote.value = 0.03

term_structure = FlatForward(
    settlement_days = settlement_days, 
    quote           = quote, 
    calendar        = NullCalendar(), 
    daycounter      = Actual360()
)

df_1 = term_structure.discount(dt_payment)

dt_today = Date(19,9,2011)
Settings().evaluation_date = dt_today 
dt_payment = Date(19,10,2011)
df_2 = term_structure.discount(dt_payment)

# df_1 and df_2 should be identical:
print('rate: %f df_1: %f df_2 %f difference: %f' % (quote.value, df_1, df_2, df_2-df_1))

# the term structure registers a listener on the quote: a change in quote
# triggers a lazy recalculation of the discount factor

quote.value = .05
df_2 = term_structure.discount(dt_payment)
print('rate: %f df_2: %f' % (quote.value, df_2))
