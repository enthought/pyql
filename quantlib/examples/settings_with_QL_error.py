# This code throws a QuantLib::Error that terminates python
# Settings is set by default to today's date.
# If dt_payment is in the past, a QuantLib::Error is thrown from c++

from quantlib.termstructures.yields.flat_forward import (
    FlatForward, YieldTermStructure
)
from quantlib.quotes.simplequote import SimpleQuote

from quantlib.settings import Settings
from quantlib.time.calendar import TARGET
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.daycounter import Actual360, Actual365Fixed
from quantlib.time.date import today, Days, Date

calendar = TARGET()

dt_today = Date(6,9,2011)
dt_payment = Date(6,12,2000)
settlement_days = 2

quote = SimpleQuote()
quote.value = 0.03

term_structure = FlatForward(
    settlement_days = settlement_days, 
    quote           = quote, 
    calendar        = NullCalendar(), 
    daycounter      = Actual360()
)

df_1 = term_structure.discount(dt_payment)
print('rate: %f df_1: %f' % (quote.value, df_1))

