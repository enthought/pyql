"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.settings import Settings
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper, SwapRateHelper
from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory
from quantlib.time.api import Date, TARGET, Period, Months, Years, Days
from quantlib.time.api import (ModifiedFollowing, Unadjusted, Actual360,
                               Thirty360, ActualActual)

from quantlib.time.api import September, ISDA, today
from quantlib.currency import USDCurrency
from quantlib.quotes import SimpleQuote

from quantlib.indexes.libor import Libor
from quantlib.time.date import Semiannual, Annual


settings = Settings()

# Market information
calendar = TARGET()

# must be a business day
eval_date = calendar.adjust(today())
settings.evaluation_date = eval_date

settlement_days = 2
settlement_date = calendar.advance(eval_date, settlement_days, Days)
# must be a business day
settlement_date = calendar.adjust(settlement_date);

depositData = [[ 1, Months, 4.581 ],
               [ 2, Months, 4.573 ],
               [ 3, Months, 4.557 ],
               [ 6, Months, 4.496 ],
               [ 9, Months, 4.490 ]]
            
swapData = [[ 1, Years, 4.54 ],
            [ 5, Years, 4.99 ],
            [ 10, Years, 5.47 ],
            [ 20, Years, 5.89 ],
            [ 30, Years, 5.96 ]]

rate_helpers = []

end_of_month = True

for m, period, rate in depositData:
    tenor = Period(m, Months)

    helper = DepositRateHelper(rate/100, tenor, settlement_days,
             calendar, ModifiedFollowing, end_of_month,
             Actual360())

    rate_helpers.append(helper)

endOfMonth = True

liborIndex = Libor('USD Libor', Period(6, Months), settlement_days,
                   USDCurrency(), calendar, ModifiedFollowing,
                   endOfMonth, Actual360())

spread = SimpleQuote(0)
fwdStart = Period(0, Days)

for m, period, rate in swapData:
    rate = SimpleQuote(rate/100)

    helper = SwapRateHelper(rate, Period(m, Years), 
        calendar, Annual,
        Unadjusted, Thirty360(),
        liborIndex, spread, fwdStart)

    rate_helpers.append(helper)
 
ts_day_counter = ActualActual(ISDA)
tolerance = 1.0e-15

ts = term_structure_factory(
    'discount', 'loglinear', settlement_date, rate_helpers,
    ts_day_counter, tolerance)

print('df: %f' % ts.discount(calendar.advance(today(), 2, Years)))
print('df: %f' % ts.discount(calendar.advance(today(), 5, Years)))
print('df: %f' % ts.discount(calendar.advance(today(), 10, Years)))
print('df: %f' % ts.discount(calendar.advance(today(), 15, Years)))
