include '../types.pxi'
from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency cimport Currency
from quantlib.time.calendar cimport Calendar

cimport quantlib._index as _in
cimport quantlib.indexes._interest_rate_index as _iri

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

from quantlib.indexes.interest_rate_index cimport InterestRateIndex

cdef class IborIndex(InterestRateIndex):
    def __cinit__(self):
        pass

#    def __init__(self,
#        familyName,
#        Period tenor,
#        Natural settlementDays,
#        Currency currency,
#        Calendar fixingCalendar,
#        DayCounter dayCounter):
    
#        self._thisptr = new shared_ptr[_in.Index](
#        new _iri.InterestRateIndex(
#            <string>familyName,
#            deref(tenor._thisptr),
#            <Natural>settlementDays,
#            deref(currency._thisptr),
#            deref(fixingCalendar._thisptr),
#            deref(dayCounter._thisptr)
#        )
#    )

cdef class OvernightIndex(IborIndex):
    def __cinit__(self):
        pass

