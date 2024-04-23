from quantlib.handle cimport shared_ptr, Handle
from quantlib._quote cimport Quote
from ._flat_forward cimport YieldTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter


cdef extern from 'ql/termstructures/yield/forwardspreadedtermstructure.hpp' namespace 'QuantLib':

    cdef cppclass ForwardSpreadedTermStructure(YieldTermStructure):

        ForwardSpreadedTermStructure(
            Handle[YieldTermStructure]& yieldtermstruct,
            Handle[Quote]& spread
        ) except +
