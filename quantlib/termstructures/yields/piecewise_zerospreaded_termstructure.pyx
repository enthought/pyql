from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from quantlib.compounding cimport Compounding, Continuous
from quantlib.handle cimport Handle
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.frequency cimport Frequency, NoFrequency
from quantlib.time._date cimport Date as QlDate
from quantlib.time.date cimport Date
from quantlib.quote cimport Quote
cimport quantlib._quote as _qt
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _piecewise_zerospreaded_termstructure as _pzt

cdef class PiecewiseZeroSpreadedTermStructure(YieldTermStructure):
    def __init__(self, HandleYieldTermStructure h not None, list spreads, list dates,
                 Compounding comp=Continuous, Frequency freq=NoFrequency,
                 DayCounter dc not None=DayCounter()):
        cdef vector[Handle[_qt.Quote]] spreads_vec
        cdef vector[QlDate] dates_vec
        cdef Quote s
        cdef Date d
        for s in spreads:
            spreads_vec.push_back(s.handle())

        for d in dates:
            dates_vec.push_back((<Date?>d)._thisptr)

        self._thisptr.reset(
            new _pzt.PiecewiseZeroSpreadedTermStructure(
                h.handle,
                spreads_vec,
                dates_vec,
                comp,
                freq,
                deref(dc._thisptr)
            )
        )
