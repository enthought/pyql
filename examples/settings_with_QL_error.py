from __future__ import print_function
# This code throws a QuantLib::Error that terminates python
# Settings is set by default to today's date.
# If dt_payment is in the past, a QuantLib::Error is thrown from c++
import logging


from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.api import FlatForward
from quantlib.time.api import Actual360, Date, NullCalendar, TARGET


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

calendar = TARGET()

date_today      = Date(6,9,2011)
date_payment    = Date(6,12,2000)
settlement_days = 2

quote = SimpleQuote(value=0.03)

term_structure = FlatForward(
    settlement_days = settlement_days,
    quote           = quote,
    calendar        = NullCalendar(),
    daycounter      = Actual360()
)

try:
    df_1 = term_structure.discount(date_payment)
    print('rate: %f df_1: %f' % (quote.value, df_1))
except RuntimeError as exc:
    logger.error('Evaluation date and discount date issue.')
    logger.exception(exc)

