from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from quantlib.handle cimport Handle, shared_ptr
from quantlib._compounding cimport Compounding, Continuous
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.frequency cimport Frequency, NoFrequency
from quantlib.time._date cimport Date as QlDate
from quantlib.time.date cimport Date
from quantlib.quote cimport Quote
cimport quantlib._quote as _qt
cimport quantlib.termstructures._yield_term_structure as _yts
from . cimport _piecewise_zerospreaded_termstructure as _pzt

cdef class PiecewiseZeroSpreadedTermStructure(YieldTermStructure):
    def __init__(self, YieldTermStructure h not None, list spreads, list dates,
                 Compounding comp=Continuous, Frequency freq=NoFrequency,
                 DayCounter dc not None=DayCounter()):
        cdef vector[Handle[_qt.Quote]] spreads_vec
        cdef vector[QlDate] dates_vec
        cdef Quote s
        cdef Date d
        for s in spreads:
            spreads_vec.push_back(s.handle())

        for d in dates:
            dates_vec.push_back(deref(d._thisptr))

        self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
            new _pzt.PiecewiseZeroSpreadedTermStructure(
                h._thisptr,
                spreads_vec,
                dates_vec,
                comp,
                freq,
                deref(dc._thisptr))))
