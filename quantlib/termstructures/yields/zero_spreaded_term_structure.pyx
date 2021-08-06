from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, make_shared, static_pointer_cast
from quantlib._compounding cimport Compounding, Continuous
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.frequency cimport Frequency, NoFrequency
from quantlib.quote cimport Quote
from .. cimport _yield_term_structure as _yts
from . cimport _zero_spreaded_term_structure as _zsts

cdef class ZeroSpreadedTermStructure(YieldTermStructure):
    def __init__(self, YieldTermStructure h not None, Quote spread,
                 Compounding comp=Continuous, Frequency freq=NoFrequency,
                 DayCounter dc not None=DayCounter()):

        self._thisptr.linkTo(static_pointer_cast[_yts.YieldTermStructure](
            make_shared[_zsts.ZeroSpreadedTermStructure](
                h._thisptr,
                spread.handle(),
                comp,
                freq,
                deref(dc._thisptr))))
