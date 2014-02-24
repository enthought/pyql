"""
Helper functions to create Ibor indices.

"""

from quantlib.indexes.libor import Libor
from quantlib.indexes.euribor import Euribor
from quantlib.market.conventions.swap import SwapData
from quantlib.termstructures.yields.yield_term_structure import (
    YieldTermStructure)
from quantlib.currency import Currency
from quantlib.time.calendar import Calendar
from quantlib.time.date import Period
from quantlib.time.daycounter import DayCounter


def create_ibor_index_from_name(market, term_structure=None, **kwargs):
    """
    Create default IBOR for the market, modify attributes if provided
    """

    row = SwapData.params(market)
    row = row._replace(**kwargs)

    # could use a dummy term structure here?
    if term_structure is None:
        term_structure = YieldTermStructure(relinkable=False)
    # may not be needed at this stage...
    # term_structure.link_to(FlatForward(settlement_date, 0.05,
    #                                       Actual365Fixed()))

    if row.currency == 'EUR':
        ibor_index = Euribor(Period(row.floating_leg_period), term_structure)
    else:
        label = row.currency + ' ' + row.floating_leg_reference
        ibor_index = Libor(label,
                           Period(row.floating_leg_period),
                           row.settlement_days,
                           Currency.from_name(row.currency),
                           Calendar.from_name(row.calendar),
                           DayCounter.from_name(row.floating_leg_daycount),
                           term_structure)

    return ibor_index
