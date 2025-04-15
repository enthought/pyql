from quantlib.types cimport Natural, Real

from quantlib.time._date cimport Date
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from ._bond cimport Bond
from ._forward cimport Forward
from quantlib.handle cimport shared_ptr, Handle
from quantlib.position cimport Position

cdef extern from "ql/instruments/bondforward.hpp" namespace "QuantLib" nogil:

    cdef cppclass BondForward(Forward):
         BondForward(
            const Date& valueDate,
            const Date& maturityDate,
            Position type,
            Real strike,
            Natural settlementDays,
            const DayCounter& dayCounter,
            const Calendar& calendar,
            BusinessDayConvention businessDayConvention,
            const shared_ptr[Bond]& bond,
            const Handle[YieldTermStructure]& discountCurve, # = Handle[YieldTermStructure](),
            const Handle[YieldTermStructure]& incomeDiscountCurve) # = Handle[YieldTermStructure]())

         Real forwardPrice() const

         Real cleanForwardPrice() const
