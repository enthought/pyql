from quantlib.types cimport Natural, Real, Volatility
from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

from quantlib.time.date cimport Date
from quantlib.time.calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.time.daycounter cimport DayCounter
from quantlib.quote cimport Quote
from ..volatilitytype cimport VolatilityType, ShiftedLognormal
from ..._vol_term_structure cimport VolatilityTermStructure
cimport quantlib.termstructures.volatility._volatilitytype as _voltype
from . cimport _swaption_constant_vol as _scv

cdef class ConstantSwaptionVolatility(SwaptionVolatilityStructure):

    def __init__(self, Natural settlement_days,
                 Calendar calendar not None,
                 BusinessDayConvention bdc,
                 volatility,
                 DayCounter day_counter not None,
                 VolatilityType vol_type=ShiftedLognormal,
                 Real shift=0.):

        if isinstance(volatility, float):
            self._thisptr.reset(
                new _scv.ConstantSwaptionVolatility(
                    settlement_days,
                    deref(calendar._thisptr),
                    bdc,
                    <Volatility>volatility,
                    deref(day_counter._thisptr),
                    <_voltype.VolatilityType>vol_type,
                    shift)
            )
        elif isinstance(volatility, Quote):
            self._thisptr.reset(
                _scv.ConstantSwaptionVolatility_(
                    settlement_days,
                    deref(calendar._thisptr),
                    bdc,
                    (<Quote>volatility).handle(),
                    deref(day_counter._thisptr),
                    <_voltype.VolatilityType>vol_type,
                    shift)
            )
        else:
            raise TypeError



    @classmethod
    def from_reference_date(cls, Date reference_date not None,
                            Calendar calendar not None,
                            BusinessDayConvention bdc,
                            volatility,
                            DayCounter day_counter not None,
                            VolatilityType vol_type=ShiftedLognormal,
                            Real shift=0.):

        cdef ConstantSwaptionVolatility instance = cls.__new__(cls)
        if isinstance(volatility, float):
            instance._thisptr.reset(
                new _scv.ConstantSwaptionVolatility(
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    bdc,
                    (<Volatility>volatility),
                    deref(day_counter._thisptr),
                    <_voltype.VolatilityType>vol_type,
                    shift
                )
            )
        elif isinstance(volatility, Quote):
            instance._thisptr.reset(
                _scv.ConstantSwaptionVolatility__(
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    bdc,
                    (<Quote>volatility).handle(),
                    deref(day_counter._thisptr),
                    <_voltype.VolatilityType>vol_type,
                    shift
                )
            )
        else:
            raise TypeError
        return instance
