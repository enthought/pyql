from cython.operator cimport dereference as deref
cimport _optionlet_volatility_structure as _ov

from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter


cdef class OptionletVolatilityStructure:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __init__(self):
        raise ValueError(
            'OptionletVolatilityStructure cannot be directly instantiated!'
        )


cdef class ConstantOptionletVolatility(OptionletVolatilityStructure):

    def __init__(self,
        int settlement_days,
        Calendar calendar,
        BusinessDayConvention bdc,
        double volatility,
        DayCounter daycounter
    ):

        self._thisptr = new shared_ptr[_ov.OptionletVolatilityStructure](
            new _ov.ConstantOptionletVolatility(
                settlement_days,
                deref(calendar._thisptr),
                bdc,
                volatility,
                deref(daycounter._thisptr)
            )
        )

