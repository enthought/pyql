include '../../../types.pxi'
from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, shared_ptr

from quantlib.time.date cimport Date
from quantlib.time.calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.time.daycounter cimport DayCounter
from quantlib.quotes cimport SimpleQuote
from ..volatilitytype cimport VolatilityType, ShiftedLognormal
cimport quantlib.termstructures.volatility._volatilitytype as _voltype
cimport _swaption_vol_structure as _svs
cimport _swaption_constant_vol as _scv
cimport quantlib._quote as _qt

cdef class ConstantSwaptionVolatility(SwaptionVolatilityStructure):

    def __init__(self, Natural settlement_days,
                 Calendar calendar not None,
                 BusinessDayConvention bdc,
                 volatility,
                 DayCounter day_counter not None,
                 VolatilityType vol_type=ShiftedLognormal,
                 Real shift=0.):
        cdef Handle[_qt.Quote] volatility_handle

        if isinstance(volatility, SimpleQuote):
            volatility_handle = Handle[_qt.Quote]((<SimpleQuote>volatility)._thisptr)
        elif isinstance(volatility, float):
            volatility_handle = Handle[_qt.Quote](
                    shared_ptr[_qt.Quote](new _qt.SimpleQuote(<Real>volatility))
            )
        else:
            raise TypeError

        self._thisptr = shared_ptr[_svs.SwaptionVolatilityStructure](
            new _scv.ConstantSwaptionVolatility(
                settlement_days,
                deref(calendar._thisptr),
                bdc,
                volatility_handle,
                deref(day_counter._thisptr),
                <_voltype.VolatilityType>vol_type,
                shift)
        )

    @classmethod
    def from_reference_date(cls, Date reference_date,
                            Calendar calendar not None,
                            BusinessDayConvention bdc,
                            volatility,
                            DayCounter day_counter not None,
                            VolatilityType vol_type=ShiftedLognormal,
                            Real shift=0.):
        cdef Handle[_qt.Quote] volatility_handle

        if isinstance(volatility, SimpleQuote):
            volatility_handle = Handle[_qt.Quote]((<SimpleQuote>volatility)._thisptr)
        elif isinstance(volatility, float):
            volatility_handle = Handle[_qt.Quote](
                    shared_ptr[_qt.Quote](new _qt.SimpleQuote(<Real>volatility))
            )
        else:
            raise TypeError

        cdef ConstantSwaptionVolatility instance = cls.__new__(cls)
        instance._thisptr = shared_ptr[_svs.SwaptionVolatilityStructure](
            new _scv.ConstantSwaptionVolatility(
                deref(reference_date._thisptr),
                deref(calendar._thisptr),
                bdc,
                volatility_handle,
                deref(day_counter._thisptr),
                <_voltype.VolatilityType>vol_type,
                shift
            )
        )
        return instance
