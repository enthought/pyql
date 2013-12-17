"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.time.calendar import TARGET
from quantlib.settings import Settings
from quantlib.time.schedule import Schedule

from quantlib.time.date import (Date, Days, Period, Months,
                                Years)
from quantlib.time.daycounter import DayCounter
from quantlib.compounding import compounding_from_name

from quantlib.util.converter import qldate_to_pydate, pydate_to_qldate

from quantlib.util.rates import make_term_structure


def zbt_libor_yield(instruments, yields, pricing_date,
                    basis='Actual/Actual (Bond)',
                    compounding_freq='Continuous',
                    maturity_dates=None):
    """
    Bootstrap a zero-coupon curve from libor rates and swap yields

    Args:

    insruments:    list of instruments, of the form Libor?M for Libor rates
                   and Swap?Y for swap rates
    yields:        market rates
    pricing_date:  the date where market data is observed. Settlement
                   is by default 2 days after pricing_date

    Optional:

    compounding_frequency: ... of zero-coupon rates. By default:
                   'Continuous'

    Returns:

    zero_rate:     zero-coupon rate
    maturity_date: ... of corresponding rate
    """

    calendar = TARGET()

    settings = Settings()
    # must be a business day
    eval_date = calendar.adjust(pydate_to_qldate(pricing_date))
    settings.evaluation_date = eval_date

    settlement_days = 2
    settlement_date = calendar.advance(eval_date, settlement_days, Days)

    rates = dict(zip(instruments, yields))
    ts = make_term_structure(rates, pricing_date)

    cnt = DayCounter.from_name(basis)

    if maturity_dates is None:
        # schedule of maturity dates from settlement date to last date on
        # the term structure

        s = Schedule(effective_date=ts.reference_date,
                     termination_date=ts.max_date,
                     tenor=Period(1, Months),
                     calendar=TARGET())
        maturity_dates = [qldate_to_pydate(dt) for dt in s.dates()]

    cp_freq = compounding_from_name(compounding_freq)
    zc = [ts.zero_rate(date=pydate_to_qldate(dt),
                       day_counter=cnt,
                       compounding=cp_freq).rate for dt in maturity_dates]

    return (maturity_dates, zc)
