from quantlib.termstructures.yields.rate_helpers import (SwapRateHelper,
                                                         DepositRateHelper)
from quantlib.quotes import SimpleQuote

from quantlib.time.api import (Date, Calendar, Period,
                               Thirty360, TARGET,
                               Actual360, ActualActual, Euro,
                               Days, Semiannual,
                               JointCalendar, UnitedStates, UnitedKingdom,
                               Annual, Years, Months,
                               Unadjusted, ModifiedFollowing)

from quantlib.time.schedule import Schedule, Backward, Forward
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure)

from quantlib.indexes.euribor import Euribor6M

from quantlib.currency import USDCurrency, EURCurrency
from quantlib.indexes.api import Libor, Euribor

from quantlib.util.converter import pydate_to_qldate

from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory


def ibor_index_factory(currency, tenor=None):
    """
    TODO: make this a class method in Ibor?
    """
    settlement_days = 2
    _default_tenor = {'USD': '3M', 'EUR': '6M'}

    # could use a dummy term structure here?
    term_structure = YieldTermStructure(relinkable=False)
    # may not be needed at this stage...
    # term_structure.link_to(FlatForward(settlement_date, 0.05,
    #                                       Actual365Fixed()))

    if(tenor is None):
        tenor = _default_tenor[currency]
    if(currency == 'USD'):
        ibor_index = Libor('USD Libor', Period(tenor), settlement_days,
                           USDCurrency(), TARGET(),
                           Actual360(), term_structure)
    elif(currency == 'EUR'):
        ibor_index = Euribor(Period(tenor), term_structure)
    return ibor_index


def usd_libor_market(index=ibor_index_factory('USD')):
    m = FixedIncomeMarket('USD Libor',
        floating_rate_index=index,
        settlement_days=2,
        fixed_rate_frequency=Semiannual,
        fixed_instrument_convention=ModifiedFollowing,
        fixed_instrument_daycounter=Thirty360())
    return m


def euribor_market(index=ibor_index_factory('EUR')):
    m = FixedIncomeMarket('Euribor',
        floating_rate_index=index,
        settlement_days=2,
        fixed_rate_frequency=Annual,
        fixed_instrument_convention=Unadjusted,
        fixed_instrument_daycounter=Thirty360())
    return m


def make_rate_helper(market, quote):
    """
    Wrapper for deposit and swaps rate helpers makers
    TODO: class method of RateHelper?
    """

    rate_type, tenor, quote_value = quote
    print rate_type, tenor, quote_value
    

    end_of_month = True

    if(rate_type == 'SWAP'):
        libor_index = market._floating_rate_index
        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)
        helper = SwapRateHelper.from_tenor(
            quote_value,
            Period(tenor),
            market._calendar, market._fixed_rate_frequency,
            market._fixed_instrument_convention,
            market._fixed_instrument_daycounter,
            libor_index, spread, fwdStart)
    elif(rate_type == 'DEP'):
        helper = DepositRateHelper(
            quote_value,
            Period(tenor),
            market._settlement_days,
            market._floating_rate_index.fixingCalendar,
            market._floating_rate_index.businessDayConvention,
            end_of_month,
            market._floating_rate_index.dayCounter)
    else:
        raise Exception("Rate type %s not supported" % rate_type)

    return (helper)


class Market:
    """
    Abstract Market class.
    A Market is a virtual environment where financial assets are traded.
    It defines the conventions for quoting prices and yield,
    for measuring time, etc.
    """

    def __init__(self, name):
        self._name = name

    @property
    def name(self):
        return self._name


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

    def __init__(self,
                 name,
                 floating_rate_index,
                 settlement_days=2,
                 fixed_rate_frequency=Annual,
                 fixed_instrument_convention=Unadjusted,
                 fixed_instrument_daycounter=Thirty360(),
                 termStructureDayCounter=ActualActual()):

        self._name = name
        self._settlement_days = settlement_days
        self._fixed_rate_frequency = fixed_rate_frequency
        self._fixed_instrument_convention = fixed_instrument_convention
        self._fixed_instrument_daycounter = fixed_instrument_daycounter
        self._termStructureDayCounter = termStructureDayCounter

        # floating rate index
        self._floating_rate_index = floating_rate_index

        self._depositDayCounter = floating_rate_index.dayCounter
        self._calendar = floating_rate_index.fixingCalendar

        self._quotes = None
        self._term_structure = None
        

    def __str__(self):
        return 'Fixed Income Market: %s' % self._name

    def set_quotes(self, dt_obs, quotes):
        self._quotes = quotes
        if(~isinstance(dt_obs, Date)):
            dt_obs = pydate_to_qldate(dt_obs)
        settings = Settings()
        calendar = JointCalendar(UnitedStates(), UnitedKingdom())
        # must be a business day
        eval_date = calendar.adjust(dt_obs)
        settings.evaluation_date = eval_date

        self._eval_date = eval_date
        
        self._rate_helpers = []
        for quote in quotes:
            # construct rate helper
            helper = make_rate_helper(self, quote)
            self._rate_helpers.append(helper)

    @property
    def calendar(self):
        return self._calendar

    @property
    def fixing_days(self):
        return self._fixing_days

    @property
    def deposit_day_counter(self):
        return self._deposit_day_counter

    @property
    def fixed_rate_frequency(self):
        return self._fixed_rate_frequency

    @property
    def fixed_rate_convention(self):
        return self._fixedInstrumentConvention

    @property
    def fixed_rate_day_counter(self):
        return self._fixed_rate_day_counter

    @property
    def ts_day_counter(self):
        return self._termstructure_day_counter

    @property
    def reference_date(self):
        return 0

    @property
    def max_date(self):
        return 0

    def bootstrap_term_structure(self):
        tolerance = 1.0e-15
        settings = Settings()
        calendar = JointCalendar(UnitedStates(), UnitedKingdom())
        # must be a business day
        eval_date = self._eval_date
        settings.evaluation_date = eval_date
        settlement_days = self._settlement_days
        settlement_date = calendar.advance(eval_date, settlement_days, Days)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date)
        ts = term_structure_factory('discount', 'loglinear',
            settlement_date, self._rate_helpers,
            self._termStructureDayCounter, tolerance)
        self._term_structure = ts
        return 0

    def discount(self, date_maturity, extrapolate=True):
        return self._term_structure.discount(date_maturity)

if __name__ == '__main__':

    # libor index

    index = ibor_index_factory('USD')
    print index

    m = usd_libor_market()
    print m

    # add quotes
    eval_date = Date(20, 9, 2004)

    quotes = [('DEP', '1W', 0.0382),
              ('DEP', '1M', 0.0372),
              ('DEP', '3M', 0.0363),
              ('DEP', '6M', 0.0353),
              ('DEP', '9M', 0.0348),
              ('DEP', '1Y', 0.0345),
              ('SWAP', '2Y', 0.037125),
              ('SWAP', '3Y', 0.0398),
              ('SWAP', '5Y', 0.0443),
              ('SWAP', '10Y', 0.05165),
              ('SWAP', '15Y', 0.055175)]

    m.set_quotes(eval_date, quotes)

    m.bootstrap_term_structure()

    dt = Date(1,1,2010)
    print('Discount factor for %s: %f' % (dt, m.discount(dt)))
