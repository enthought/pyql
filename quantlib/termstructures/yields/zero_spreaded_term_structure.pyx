from cython.operator cimport dereference as deref
from quantlib.compounding cimport Compounding
from quantlib.handle cimport HandleYieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.frequency cimport Frequency, NoFrequency
from quantlib.quote cimport Quote
from . cimport _zero_spreaded_term_structure as _zsts

cdef class ZeroSpreadedTermStructure(YieldTermStructure):
    def __init__(self, HandleYieldTermStructure h not None, Quote spread,
                 Compounding comp=Compounding.Continuous, Frequency freq=NoFrequency,
                 DayCounter dc not None=DayCounter()):

        self._thisptr.reset(
            new _zsts.ZeroSpreadedTermStructure(
                h.handle(),
                spread.handle(),
                comp,
                freq,
                deref(dc._thisptr)
            )
        )
