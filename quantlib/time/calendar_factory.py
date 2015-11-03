from quantlib.time.calendar import TARGET

from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.calendars.germany import (
    Germany, EUREX, FrankfurtStockExchange, SETTLEMENT as GER_SETTLEMENT,
    EUWAX, XETRA)

from quantlib.time.calendars.united_kingdom import (
    EXCHANGE, METALS, SETTLEMENT as UK_SETTLEMENT,
    UnitedKingdom)

from quantlib.time.calendars.united_states import (
    UnitedStates, GOVERNMENTBOND, NYSE, NERC, SETTLEMENT as US_SETTLEMENT)

class CalendarFactory:
    _lookup = dict([(cal.name(), cal) for cal in
                    [TARGET(), NullCalendar(),
                     Germany(), Germany(EUREX),
                     Germany(FrankfurtStockExchange),
                     Germany(GER_SETTLEMENT), Germany(EUWAX), Germany(XETRA),
                     UnitedKingdom(),
                     UnitedKingdom(EXCHANGE), UnitedKingdom(METALS),
                     UnitedKingdom(UK_SETTLEMENT),
                     UnitedStates(), UnitedStates(GOVERNMENTBOND),
                     UnitedStates(NYSE), UnitedStates(NERC),
                     UnitedStates(US_SETTLEMENT) ]
    ])

def calendar_factory(name):
    return _lookup[name]
