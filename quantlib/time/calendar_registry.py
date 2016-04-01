from .calendars.null_calendar import NullCalendar
from .calendars.weekends_only import WeekendsOnly
from .calendars.germany import (EUREX, FRANKFURT_STOCK_EXCHANGE, EUWAX, XETRA)
from .calendars.united_kingdom import (EXCHANGE, METALS)
from .calendars.united_states import (GOVERNMENTBOND, NYSE, NERC)
from .calendars import *
from .calendar import TARGET
from ..util.object_registry import ObjectRegistry

#ISO-3166 country codes (http://en.wikipedia.org/wiki/ISO_3166-1)
ISO_3166_CALENDARS = {
    'TARGET': TARGET(),
    'NULL': NullCalendar(),
    'WO': WeekendsOnly(),
    'DEU': Germany(),
    'EUREX': Germany(EUREX),
    'FSE': Germany(FRANKFURT_STOCK_EXCHANGE),
    'EUWAX': Germany(EUWAX),
    'XETRA': Germany(XETRA),
    'GBR': UnitedKingdom(),
    'LSE': UnitedKingdom(EXCHANGE),
    'LME': UnitedKingdom(METALS),
    'USA': UnitedStates(),
    'USA-GVT-BONDS': UnitedStates(GOVERNMENTBOND),
    'NYSE': UnitedStates(NYSE),
    'NERC': UnitedStates(NERC),
    'JPN': Japan(),
    'CHE': Switzerland(),
    'CAN': Canada(),
}


def initialize_code_registry():
    registry = ObjectRegistry('Calendar')

    for code, calendar in ISO_3166_CALENDARS.items():
        registry.register(code, calendar)

    return registry

def initialize_name_registry():
    registry = ObjectRegistry('Calendar')

    for calendar in ISO_3166_CALENDARS.values():
        registry.register(calendar.name, calendar)

    return registry

code_registry = initialize_code_registry()
name_registry = initialize_name_registry()
calendar_from_name = code_registry.from_name
calendar_from_internal_name = name_registry.from_name
