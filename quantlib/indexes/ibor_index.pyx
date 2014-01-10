include '../types.pxi'
from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency cimport Currency
from quantlib.time.calendar cimport Calendar

cimport quantlib._index as _in
cimport quantlib.indexes._ibor_index as _ib

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

from quantlib.indexes.interest_rate_index cimport InterestRateIndex

cdef class IborIndex(InterestRateIndex):
    def __cinit__(self):
        pass

    property businessDayConvention:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.businessDayConvention()

    property endOfMonth:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.endOfMonth()

cdef class OvernightIndex(IborIndex):
    def __cinit__(self):
        pass

