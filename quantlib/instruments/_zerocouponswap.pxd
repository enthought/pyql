from quantlib.types cimport Natural, Rate, Real
from quantlib.handle cimport shared_ptr
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.indexes._ibor_index cimport IborIndex
from .swap cimport Type
from ._swap cimport Swap

cdef extern from "ql/instruments/zerocouponswap.hpp" namespace "QuantLib" nogil:
    cdef cppclass ZeroCouponSwap(Swap):
        ZeroCouponSwap(Type type,
                       Real baseNominal,
                       const Date& startDate,
                       const Date& maturityDate,
                       Real fixedPayment,
                       shared_ptr[IborIndex] iborIndex,
                       const Calendar& paymentCalendar,
                       BusinessDayConvention paymentConvention,# = Following,
                       Natural paymentDelay) # = 0

        ZeroCouponSwap(Type type,
                       Real baseNominal,
                       const Date& startDate,
                       const Date& maturityDate,
                       Rate fixedRate,
                       const DayCounter& fixedDayCounter,
                       shared_ptr[IborIndex] iborIndex,
                       const Calendar& paymentCalendar,
                       BusinessDayConvention paymentConvention,# = Following,
                       Natural paymentDelay) # = 0)
