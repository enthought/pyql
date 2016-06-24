include '../../types.pxi'

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

cimport _zero_curve as _zc
from quantlib.handle cimport shared_ptr, Handle
from flat_forward cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date

cdef class ZeroCurve(YieldTermStructure):

    def __init__(self, list dates, vector[Rate] yields, DayCounter daycounter):

        # convert dates and yields to vector
        cdef vector[_zc.Date] _date_vector = vector[_zc.Date]()

        # highly inefficient and could be improved
        for date in dates:
            _date_vector.push_back(deref((<Date>date)._thisptr.get()))

        # create the curve
        self._thisptr = new shared_ptr[Handle[_zc.YieldTermStructure]](
            new Handle[_zc.YieldTermStructure](shared_ptr[_zc.YieldTermStructure](
                new _zc.ZeroCurve(
                    _date_vector,
                    yields,
                    deref(daycounter._thisptr)))
            )
        )
