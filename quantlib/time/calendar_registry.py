from quantlib.util.prettyprint import prettyprint

class CalendarRegistry(object):

    def __init__(self):

        self._lookup = dict()
        self._code = dict()
        self._inv_code = dict()
        self._initalized = False

    def help(self):
        tmp = map(list, zip(*self._code))
        res = "Valid calendar names are:\n\n" + prettyprint(('Code', 'Calendar'), 'ss', tmp)
        return res

    def from_name(self, code):
        """ Returns an instance of the calendar for the given code. """
        if not self._initialized:
            self._intitialize()
        # FIXME: from_name seems to be from_code
        return self._lookup[self._code[code]]

    def register_calendar(self, iso_code, calendar):
        _name = calendar.name
        if _name not in self._lookup:
            self._lookup[_name] = calendar
            self._code[iso_code] = _name

    def _initialize(self):
        
        from quantlib.time.calendars.null_calendar import NullCalendar
        import quantlib.time.calendars.germany as ger
        import quantlib.time.calendars.united_states as us
        import quantlib.time.calendars.united_kingdom as uk
        import quantlib.time.calendars.japan as jp
        import quantlib.time.calendars.switzerland as sw
        from quantlib.time.calendar import TARGET

        #ISO-3166 country codes (http://en.wikipedia.org/wiki/ISO_3166-1)
        self.register_calendar('TARGET', TARGET())
        self.register_calendar('NULL', NullCalendar())
        self.register_calendar('DEU', ger.Germany())
        self.register_calendar('EUREX', ger.Germany(ger.EUREX))
        self.register_calendar('FSE', ger.Germany(ger.FRANKFURT_STOCK_EXCHANGE))
        self.register_calendar('EUWAX', ger.Germany(ger.EUWAX))
        self.register_calendar('XETRA', ger.Germany(ger.XETRA))
        self.register_calendar('GBR', uk.UnitedKingdom())
        self.register_calendar('LSE', uk.UnitedKingdom(uk.EXCHANGE))
        self.register_calendar('LME', uk.UnitedKingdom(uk.METALS))
        self.register_calendar('USA', us.UnitedStates())
        self.register_calendar('USA-GVT-BONDS', us.UnitedStates(us.GOVERNMENTBOND))
        self.register_calendar('NYSE', us.UnitedStates(us.NYSE_))
        self.register_calendar('NERC', us.UnitedStates(us.NERC_))
        self.register_calendar('JPN', jp.Japan())
        self.register_calendar('CHE', sw.Switzerland())

        self._initialized = True


_registry = CalendarRegistry()

register_calendar = _registry.register_calendar
calendar_from_name = _registry.from_name