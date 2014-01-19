from quantlib.termstructures.yields.rate_helpers import (SwapRateHelper,
                                                         DepositRateHelper)
from quantlib.quotes import SimpleQuote

from quantlib.time.api import (Date, Period,
                               Days, JointCalendar, UnitedStates,
                               UnitedKingdom,
                               ModifiedFollowing)
from quantlib.time.date import code_to_frequency
from quantlib.time.daycounter import DayCounter

from quantlib.settings import Settings
from quantlib.indexes.api import IborIndex

from quantlib.util.converter import pydate_to_qldate

from quantlib.termstructures.yields.piecewise_yield_curve import \
    term_structure_factory

from quantlib.market.conventions.swap import SwapData


def libor_market(market='USD(NY)', **kwargs):
    m = IborMarket('USD Libor', market, **kwargs)
    return m


def make_rate_helper(market, quote):
    """
    Wrapper for deposit and swaps rate helpers makers
    TODO: class method of RateHelper?
    """

    rate_type, tenor, quote_value = quote

    if(rate_type == 'SWAP'):
        libor_index = market._floating_rate_index
        spread = SimpleQuote(0)
        fwdStart = Period(0, Days)
        helper = SwapRateHelper.from_tenor(
            quote_value,
            Period(tenor),
            market._floating_rate_index.fixingCalendar,
            code_to_frequency(market._fixed_rate_frequency),
            market._fixed_instrument_convention,
            DayCounter.from_name(market._fixed_instrument_daycounter),
            libor_index, spread, fwdStart)
    elif(rate_type == 'DEP'):
        end_of_month = True
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

    pass


class IborMarket(FixedIncomeMarket):

    def __init__(self, name, market, **kwargs):

        index = IborIndex.from_name(market, **kwargs)

        row = SwapData.params(market)
        row = row._replace(**kwargs)

        self._name = name
        self._settlement_days = row.fixing_days
        self._fixed_rate_frequency = row.fixed_leg_period
        ## FIXME: add this to swap data set
        self._fixed_instrument_convention = ModifiedFollowing
        self._fixed_instrument_daycounter = row.fixed_leg_daycount
        self._termstructure_daycounter = row.fixed_leg_daycount

        # floating rate index
        self._floating_rate_index = index

        self._deposit_daycounter = row.floating_leg_daycount
        self._calendar = row.calendar

        self._eval_date = None
        self._quotes = None
        self._termstructure = None

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
    def settlement_days(self):
        return self._settlement_days

    @property
    def deposit_daycounter(self):
        return self._deposit_daycounter

    @property
    def fixed_rate_frequency(self):
        return self._fixed_rate_frequency

    @property
    def fixed_rate_convention(self):
        return self._fixed_instrument_convention

    @property
    def fixed_rate_daycounter(self):
        return self._fixed_rate_daycounter

    @property
    def termstructure_daycounter(self):
        return self._termstructure_daycounter

    @property
    def reference_date(self):
        return 0

    @property
    def max_date(self):
        return 0

    def to_str(self):
        str = "Ibor Market %s\n" % self._name + \
              "Number of settlement days: %d\n" % self._settlement_days + \
              "Fixed rate frequency: %s\n" % self._fixed_rate_frequency + \
              "Fixed rate convention: %s\n" % self._fixed_instrument_convention + \
              "Fixed rate daycount: %s\n" % self._fixed_instrument_daycounter + \
              "Term structure daycount: %s\n" % self._termstructure_daycounter + \
              "Floating rate index: %s\n" % self._floating_rate_index + \
              "Deposit daycount: %s\n" % self._deposit_daycounter + \
              "Calendar: %s\n" % self._calendar

        return str

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
                                    DayCounter.from_name(self._termstructure_daycounter),
                                    tolerance)
        self._term_structure = ts
        return 0

    def discount(self, date_maturity, extrapolate=True):
        return self._term_structure.discount(date_maturity)

