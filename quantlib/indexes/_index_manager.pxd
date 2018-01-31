include '../types.pxi'

from quantlib.time._date cimport Date
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from quantlib._time_series cimport TimeSeries

cdef extern from "ql/indexes/indexmanager.hpp" namespace "QuantLib":
    cdef cppclass IndexManager:
        bool hasHistory(const string& name)
        TimeSeries[Real] getHistory(string& name)
        setHistory(string& name, const TimeSeries[Real]&)
        vector[string] histories()
        void clearHistory(const string name)
        void clearHistories()
        @staticmethod
        IndexManager& instance()
