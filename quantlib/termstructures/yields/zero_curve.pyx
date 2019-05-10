include '../../types.pxi'

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

from . cimport _zero_curve as _zc
from quantlib.handle cimport shared_ptr
from .flat_forward cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date

cdef class ZeroCurve(YieldTermStructure):

    def __init__(self, list dates, vector[Rate] yields, DayCounter daycounter not None):

        # convert dates and yields to vector
        cdef vector[_zc.Date] _date_vector
        cdef Date d
        # highly inefficient and could be improved
        for d in dates:
            _date_vector.push_back(deref(d._thisptr))

        # create the curve
        self._thisptr.linkTo(shared_ptr[_zc.YieldTermStructure](
                new _zc.ZeroCurve(
                    _date_vector,
                    yields,
                    deref(daycounter._thisptr)))
            )
