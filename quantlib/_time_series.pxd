include 'types.pxi'
from libcpp.map cimport map
from quantlib.time._date cimport Date
from libcpp.vector cimport vector
from libcpp cimport bool

cdef extern from "ql/timeseries.hpp" namespace "QuantLib" nogil:
    cdef cppclass TimeSeries[T](map[Date,T]):
        TimeSeries()
        TimeSeries(vector[Date].iterator dBegin, vector[Date].iterator dEnd, vector[T].iterator vBegin)
        Date firstDate()
        Date lastDate()
        vector[T] values()
        vector[Date] dates()
