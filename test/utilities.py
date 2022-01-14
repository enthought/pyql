from quantlib.time.api import Actual365Fixed, NullCalendar
from quantlib.termstructures.yields.api import FlatForward

def flat_rate(rate, dc=Actual365Fixed()):
     return FlatForward(
        settlement_days=0, calendar=NullCalendar(), forward=rate, daycounter=dc)
