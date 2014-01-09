from quantlib.termstructures.yields.rate_helpers import RateHelper
from quantlib.quotes import Quote
from quantlib.time.api import (Daycounter, Calendar, Period,
                               BusinessDayConvention,
                               Frequency)


def ibor_index_factory(currency):
    settlement_days = 2
    if(currency == 'USD'):
        ibor_index = Libor('USD Libor', Period('3M'), settlement_days,
                        USDCurrency(), calendar, Actual360())
    elif(currency == 'EUR'):
        ibor_index = Libor('Euribor', Period('6M'), settlement_days,
                        EURCurrency(), calendar, Actual360())
    return ibor_index

def usd_libor_market(index):
    m = FixedIncomeMarket( 
        quotes=None,
        floating_rate_index=index,
        settlement_days=2,
        fixed_rate_frequency=SemiAnnual,
        fixed_instrument_convention=ModifiedFollowing,
        fixed_instrument_daycounter=Thirty360(EUROPEAN))
    return m

def euribor_market(index):
    m = FixedIncomeMarket( 
        quotes=None,
        floating_rate_index=index,
        settlement_days=2,
        fixed_rate_frequency=Annual,
        fixed_instrument_convention=Unadjusted,
        fixed_instrument_daycounter=Thirty360(EUROPEAN))
    return m

class Market:
    """
    Abstract Market class.
    A Market is a virtual environment where financial assets are traded.
    It defines the conventions for quoting prices and yield,
    for measuring time, etc.
    """

    def __init__(self, name):
        self._name = name

    property name:
        def __get__(self):
            return(self._name)

def make_rate_helper(market, quote, dt_obs):
    """
    Wrapper for deposit and swaps rate helpers makers
    """

    rate_type, tenor, quote_value = quote
    quote_value = SimpleQuote(quote_value)
    
    if(~isinstance(dt_obs, quantlib.time.date.Date)):
        dt_obs = pydate_to_qldate(dt_obs)
    settings = Settings()
    calendar = JointCalendar(UnitedStates(), UnitedKingdom())
    # must be a business day
    eval_date = calendar.adjust(dt_obs)
    settings.evaluation_date = eval_date
    settlement_days = 2
    settlement_date = calendar.advance(eval_date, market.settlement_days, Days)
    # must be a business day
    settlement_date = calendar.adjust(settlement_date)
    end_of_month = True

    if(rate_type == 'SWAP'):
        liborIndex = market._floating_rate_index
        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)
        helper = SwapRateHelper.from_tenor(quote_value,
                 Period(tenor),
                 calendar, market._fixed_rate_frequency,
                 market._fixed_instrument_convention,
                 market._fixed_instrument_daycounter,
                 liborIndex, spread, fwdStart)
    elif(rate_type == 'DEP'):
        helper = DepositRateHelper(quote_value,
                 Period(tenor),
                 settlement_days,
                 market._floating_rate_index.fixingCalendar()
                 market._floating_rate_index.businessDayConvention(),
                 end_of_month,
                 market._floating_rate_index.dayCounter())
    else:
        raise Exception("Rate type %s not supported" % label)


    return (helper)

class FixedIncomeMarket(Market):
    """
    A Fixed Income Market, defined by:
    - a list of benchmarks instruments (deposits, FRA, swaps,
      EuroDollar futures, bonds)
    - a set of market conventions, needed to interpreted the quoted
      prices of benchmark instruments, and for computing
      derived quantities (yield curves)

    This class models an homogeneous market: It is assumed that the
    market conventions for all fixed rate instruments, including swaps,
    are all consistent. The conventions may vary between the fixed rate
    instruments and the deposit instruments.
    """

    def __init__(self, quotes,
                 floating_rate_index,
                 settlement_days=2,
                 fixed_rate_frequency=Annual,
                 fixed_instrument_convention=Unadjusted,
                 fixed_instrument_daycounter=Thirty360(),
                 termStructureDayCounter=ActualActual()):

        self._settlement_days = settlement_days
        self._fixed_rate_frequency = fixed_rate_frequency
        self._fixed_instrument_convention = fixed_instrument_convention
        self._fixed_instrument_daycounter = fixed_instrument_daycounter
        self._termStructureDayCounter = termStructureDayCounter

        # floating rate index
        self._floating_rate_index = floating_rate_index
        ## Libor('USD Libor', market.Period(6, Months),
        ##                settlement_days,
        ##                market._currency, calendar,
        ##                Actual360())

            self._floating_rate_index.businessDayConvention()
        self._depositDayCounter = self.floatingRateIndex.dayCounter()
        self._calendar = self.floatingRateIndex.fixingCalendar()

        # convert quotes to std::vector of rate_helpers
        self._quotes = quotes
        self._rate_helpers = []
        for quote in self._quotes:
            # construct rate helper
            helper = NULL
            self._rate_helpers.append(helper)

    def __str__(self):
        return 'Fixed Income Market: %s' % self._name

    def set_quotes(self, quotes):
        self._quotes = quotes
        self._rate_helpers = []
        for quote in quotes:
            # construct rate helper
            helper = ?
            self._rate_helpers.append(helper)

    def update(FixedIncomeMarket a_market) {
        self._calendar = a_market._calendar
        self._fixingDays = a_market._fixingDays
        self._depositDayCounter = a_market._depositDayCounter
        self._businessDayConvention = a_market._businessDayConvention

        self._fixedInstrumentFrequency = \
        a_market._fixedInstrumentFrequency
        self._fixedInstrumentConvention = \
        a_market._fixedInstrumentConvention
        self._fixedInstrumentDayCounter = \
        a_market._fixedInstrumentDayCounter
        self._fixedRateFrequency = a_market._fixedRateFrequency

        self._floatingRateIndex = a_market._floatingRateIndex
        self._termStructureDayCounter = \
        a_market._termStructureDayCounter

    property calendar:
        def __get__(self):
            return self._calendar

    property fixing_days:
        def __get__(self):
            return self._fixingDays

    property deposit_day_counter:
        def __get__(self):
            return self._depositDayCounter

    property fixed_rate_frequency:
        def __get__(self):
            return _fixedInstrumentFrequency

    property fixed_rate_convention:
        def __get__(self):
            return self._fixedInstrumentConvention

    property fixed_rate_day_counter:
        def __get__(self):
            return self._fixedInstrumentDayCounter

    property ts_day_counter:
        def __get__(self):
            return self._termStructureDayCounter

    property reference_date:
        def __get__(self):
            return 0

    property max_date:
        def __get__(self):
            return 0

    def bootstrap_term_structure(self):
        return 0

    def discount(self, double maturity, bool extrapolate=True):
        return 0

    def discount(Date maturity_date, bool extrapolate=false):
        return 0
