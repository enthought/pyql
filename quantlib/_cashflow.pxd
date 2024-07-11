from quantlib.types cimport Real
from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, optional
from quantlib.time._date cimport Date

cdef extern from 'ql/event.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Event:
        Date date()
        bool hasOccurred(Date& refDate,
                         optional[bool] includeRefDate)

cdef extern from 'ql/cashflow.hpp' namespace 'QuantLib' nogil:
    cdef cppclass CashFlow(Event):
        Real amount() except +

    ctypedef vector[shared_ptr[CashFlow]] Leg

cdef extern from 'ql/cashflows/simplecashflow.hpp' namespace 'QuantLib' nogil:
    cdef cppclass SimpleCashFlow(CashFlow):
        SimpleCashFlow(Real amount,
                       Date& date)
