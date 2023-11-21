from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.calendars.weekends_only import WeekendsOnly
import quantlib.time.calendars.germany as ger
import quantlib.time.calendars.united_states as us
import quantlib.time.calendars.united_kingdom as uk
import quantlib.time.calendars.japan as jp
import quantlib.time.calendars.switzerland as sw
import quantlib.time.calendars.canada as ca
from quantlib.time.calendars.target import TARGET
from quantlib.util.object_registry import ObjectRegistry

#ISO-3166 country codes (http://en.wikipedia.org/wiki/ISO_3166-1)
ISO_3166_CALENDARS = {
    'TARGET': TARGET(),
    'NULL': NullCalendar(),
    'WO': WeekendsOnly(),
    'DEU': ger.Germany(),
    'EUREX': ger.Germany(ger.Eurex),
    'FSE': ger.Germany(ger.FrankfurtStockExchange),
    'EUWAX': ger.Germany(ger.Euwax),
    'XETRA': ger.Germany(ger.Xetra),
    'GBR': uk.UnitedKingdom(),
    'LSE': uk.UnitedKingdom(uk.Market.Exchange),
    'LME': uk.UnitedKingdom(uk.Market.Metals),
    'USA': us.UnitedStates(),
    'USA-GVT-BONDS': us.UnitedStates(us.Market.GovernmentBond),
    'NYSE': us.UnitedStates(us.Market.NYSE),
    'NERC': us.UnitedStates(us.Market.NERC),
    'JPN': jp.Japan(),
    'CHE': sw.Switzerland(),
    'CAN': ca.Canada(),
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
