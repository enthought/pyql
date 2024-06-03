from quantlib.types cimport Natural, Spread

from libcpp cimport bool

from cython.operator cimport dereference as deref
from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.termstructures.helpers cimport Pillar
from quantlib.handle cimport shared_ptr, static_pointer_cast, Handle, optional
from quantlib.quote cimport Quote
from quantlib.time.date cimport Date, Period
from quantlib.termstructures.yields.rate_helpers cimport RelativeDateRateHelper, RateHelper
from quantlib.indexes.ibor_index cimport OvernightIndex
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
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
                 Period tenor not None, # swap maturity
                 Quote fixed_rate not None,
                 OvernightIndex overnight_index not None,
                 # exogenous discounting curve
                 HandleYieldTermStructure ts not None=HandleYieldTermStructure(),
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
                 end_of_month=None,
                 ):
        cdef optional[bool] end_of_month_opt
        if end_of_month is not None:
            end_of_month_opt = <bool>end_of_month
        self._thisptr = shared_ptr[_rh.RateHelper](
            new _orh.OISRateHelper(
                settlement_days,
                deref(tenor._thisptr),
                fixed_rate.handle(),
                static_pointer_cast[_ib.OvernightIndex](overnight_index._thisptr),
                ts.handle,
                telescopic_value_dates,
                payment_lag,
                <_rh.BusinessDayConvention> payment_convention,
                <Frequency> payment_frequency,
                payment_calendar._thisptr,
                deref(forward_start._thisptr),
                overnight_spread,
                pillar,
                custom_pillar_date._thisptr,
                averaging_method,
                end_of_month_opt,
            )
        )

cdef class DatedOISRateHelper(RateHelper):

    def __init__(self,
                 Date start_date not None,
                 Date end_date not None,
                 Quote fixed_rate not None,
                 OvernightIndex overnight_index not None,
                 # exogenous discounting curve
                 HandleYieldTermStructure discounting_curve not None=HandleYieldTermStructure(),
                 bool telescopic_value_dates = False,
                 RateAveraging averaging_method=RateAveraging.Compound,
                 ):
        self._thisptr = shared_ptr[_rh.RateHelper](
            new _orh.DatedOISRateHelper(
                start_date._thisptr,
                end_date._thisptr,
                fixed_rate.handle(),
                static_pointer_cast[_ib.OvernightIndex](overnight_index._thisptr),
                discounting_curve.handle,
                telescopic_value_dates,
                averaging_method
            )
        )
