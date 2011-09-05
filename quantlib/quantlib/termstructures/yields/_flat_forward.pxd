# distutils: language = c++
# distutils: libraries = QuantLib

include '../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, Handle, RelinkableHandle
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Frequency

cdef extern from 'ql/quote.hpp' namespace 'QuantLib':
    cdef cppclass Quote:
        Quote()
        Real value()
        bool isValid()

cdef extern from 'ql/quotes/simplequote.hpp' namespace 'QuantLib':
    cdef cppclass SimpleQuote(Quote):
        SimpleQuote(Real value)
        Real setValue(Real value)

cdef extern from 'ql/compounding.hpp' namespace 'QuantLib':
    cdef enum Compounding:
        Simple = 0
        Compounded = 1
        Continuous = 2
        SimpleThenCompounded = 3

cdef extern from 'ql/termstructures/yieldtermstructure.hpp' namespace 'QuantLib':
    cdef cppclass YieldTermStructure:
        YieldTermStructure()
        YieldTermStructure(DayCounter& dc,
                           vector[Handle[Quote]]& jumps,
                           vector[Date]& jumpDates,
                           )
        DiscountFactor discount(Date& d)
        DiscountFactor discount(Date& d, bool extrapolate)
        DiscountFactor discount(Time t)
        DiscountFactor discount(Time t, bool extrapolate)
        Date& referenceDate()

cdef extern from 'ql/termstructures/yield/flatforward.hpp' namespace 'QuantLib':

    cdef cppclass FlatForward(YieldTermStructure):

        FlatForward(DayCounter& dc,
                   vector[Handle[Quote]]& jumps,
                   vector[Date]& jumpDates,
        )


        FlatForward(Date& referenceDate,
                   Rate forward,
                   DayCounter& dayCounter,
                   Compounding compounding,
                   Frequency frequency
        )

        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Rate forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
                    Frequency frequency
        )

        # from days and quote :
        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Handle[Quote]& forward,
                    DayCounter& dayCounter,
        ) 
        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Handle[Quote]& forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
        ) 
        FlatForward(Natural settlementDays,
                    Calendar& calendar,
                    Handle[Quote]& forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
                    Frequency frequency
        ) 
        # from date and forward
        FlatForward(Date& referenceDate,
                    Handle[Quote]& forward,
                    DayCounter& dayCounter,
                    Compounding compounding,
                    Frequency frequency
        )
