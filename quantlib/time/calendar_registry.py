import tabulate

class CalendarRegistry(object):

    def __init__(self):

        self._lookup = dict()
        self._code = dict()
        self._inv_code = dict()
        self._initialized = False

    def help(self):
        table = tabulate.tabulate(self._code.iteritems(), headers=['Code', 'Calendar'])
        help_str = "Valid calendar names are:\n\n{}".format(table) 
        return help_str

    def from_name(self, code):
        """ Returns an instance of the calendar for the given ISO-3166 code. """
        if not self._initialized:
            self._initialize()
        if code not in self._code:
            raise ValueError('Unkown ISO-3166 code in registered calendars')
        return self._lookup[self._code[code]]

    def from_internal_name(self, name):
        """ Returns an instance of the internal calendar name """
        if not self._initialized:
            self._initialize()
        return self._lookup[name]
        
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
        self.register_calendar('NYSE', us.UnitedStates(us.NYSE))
        self.register_calendar('NERC', us.UnitedStates(us.NERC))
        self.register_calendar('JPN', jp.Japan())
        self.register_calendar('CHE', sw.Switzerland())

        self._initialized = True


_registry = CalendarRegistry()

register_calendar = _registry.register_calendar
calendar_from_name = _registry.from_name
calendar_from_internal_name = _registry.from_internal_name