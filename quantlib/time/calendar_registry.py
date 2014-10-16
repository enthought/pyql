import tabulate

class ObjectRegistry(object):

    def __init__(self, name):

        self._name = name
        self._lookup = dict()

    def help(self):
        table = tabulate.tabulate(
            self._lookup.iteritems(), headers=['Name', self._name.capitalize()]
        )
        help_str = "Valid names are:\n\n{0}".format(table)
        return help_str

    def from_name(self, name):
        """ Returns an instance for the given code. """
        if name not in self._lookup:
            raise ValueError('Unkown name in registry')
        return self._lookup[name]

    def register_calendar(self, name, calendar):
        if name not in self._lookup:
            self._lookup[name] = calendar

from quantlib.time.calendars.null_calendar import NullCalendar
import quantlib.time.calendars.germany as ger
import quantlib.time.calendars.united_states as us
import quantlib.time.calendars.united_kingdom as uk
import quantlib.time.calendars.japan as jp
import quantlib.time.calendars.switzerland as sw
from quantlib.time.calendar import TARGET

#ISO-3166 country codes (http://en.wikipedia.org/wiki/ISO_3166-1)
ISO_3166_CALENDARS = {
    'TARGET': TARGET(),
    'NULL': NullCalendar(),
    'DEU': ger.Germany(),
    'EUREX': ger.Germany(ger.EUREX),
    'FSE': ger.Germany(ger.FRANKFURT_STOCK_EXCHANGE),
    'EUWAX': ger.Germany(ger.EUWAX),
    'XETRA': ger.Germany(ger.XETRA),
    'GBR': uk.UnitedKingdom(),
    'LSE': uk.UnitedKingdom(uk.EXCHANGE),
    'LME': uk.UnitedKingdom(uk.METALS),
    'USA': us.UnitedStates(),
    'USA-GVT-BONDS': us.UnitedStates(us.GOVERNMENTBOND),
    'NYSE': us.UnitedStates(us.NYSE),
    'NERC': us.UnitedStates(us.NERC),
    'JPN': jp.Japan(),
    'CHE': sw.Switzerland()
}


def initialize_code_registry():
    registry = ObjectRegistry('Calendar')

    for code, calendar in ISO_3166_CALENDARS.items():
        registry.register_calendar(code, calendar)

    return registry

def initialize_name_registry():
    registry = ObjectRegistry('Calendar')

    for calendar in ISO_3166_CALENDARS.values():
        registry.register_calendar(calendar.name, calendar)

    return registry

code_registry = initialize_code_registry()
name_registry = initialize_name_registry()
calendar_from_name = code_registry.from_name
calendar_from_internal_name = name_registry.from_name
