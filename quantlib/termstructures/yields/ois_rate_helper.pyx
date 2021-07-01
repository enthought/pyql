from quantlib.types cimport Natural, Spread

from libcpp cimport bool

from cython.operator cimport dereference as deref
from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.termstructures.helpers cimport Pillar
from quantlib.handle cimport shared_ptr, static_pointer_cast, Handle
from quantlib.quote cimport Quote
from quantlib.time.date cimport Date, Period
from quantlib.termstructures.yields.rate_helpers cimport RelativeDateRateHelper, RateHelper
from quantlib.indexes.ibor_index cimport OvernightIndex
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time.calendar cimport Calendar

from . cimport _ois_rate_helper as _orh
from . cimport _rate_helpers as _rh
cimport quantlib._quote as _qt
cimport quantlib.indexes._ibor_index as _ib
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following
from quantlib.time._period cimport Frequency, Days
cimport quantlib.termstructures._yield_term_structure as _yts

cdef class OISRateHelper(RelativeDateRateHelper):

    def __init__(self,
                 Natural settlement_days,
                 Period tenor, # swap maturity
                 Quote fixed_rate,
                 OvernightIndex overnight_index not None,
                 # exogenous discounting curve
                 YieldTermStructure ts not None=YieldTermStructure(),
                 bool telescopic_value_dates = False,
                 Natural payment_lag = 0,
                 BusinessDayConvention payment_convention = Following,
                 Frequency payment_frequency = Frequency.Annual,
                 Calendar payment_calendar = Calendar(),
                 Period forward_start = Period(0, Days),
                 Spread overnight_spread = 0.0,
                 Pillar pillar=Pillar.LastRelevantDate,
                 Date custom_pillar_date=Date(),
                 RateAveraging averaging_method=RateAveraging.Compound,
                 ):
        self._thisptr = shared_ptr[_rh.RateHelper](
            new _orh.OISRateHelper(
                settlement_days,
                deref(tenor._thisptr),
                Handle[_qt.Quote](fixed_rate._thisptr),
                static_pointer_cast[_ib.OvernightIndex](overnight_index._thisptr),
                ts._thisptr,
                telescopic_value_dates,
                payment_lag,
                <_rh.BusinessDayConvention> payment_convention,
                <Frequency> payment_frequency,
                deref(payment_calendar._thisptr),
                deref(forward_start._thisptr),
                overnight_spread,
                pillar,
                deref(custom_pillar_date._thisptr),
                averaging_method
            )
        )

cdef class DatedOISRateHelper(RateHelper):

    def __init__(self,
                 Date start_date,
                 Date end_date,
                 Quote fixed_rate,
                 OvernightIndex overnight_index not None,
                 # exogenous discounting curve
                 YieldTermStructure discounting_curve not None=YieldTermStructure(),
                 bool telescopic_value_dates = False,
                 RateAveraging averaging_method=RateAveraging.Compound,
                 ):
        self._thisptr = shared_ptr[_rh.RateHelper](
            new _orh.DatedOISRateHelper(
                deref(start_date._thisptr),
                deref(end_date._thisptr),
                Handle[_qt.Quote](fixed_rate._thisptr),
                static_pointer_cast[_ib.OvernightIndex](overnight_index._thisptr),
                discounting_curve._thisptr,
                telescopic_value_dates,
                averaging_method
            )
        )
