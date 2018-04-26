include '../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.time._date cimport Date
from libcpp.string cimport string

cdef extern from 'ql/instrument.hpp' namespace 'QuantLib':
    cdef cppclass Instrument:
        Instrument()

        Real NPV() except +
        Date& valuationDate()
        void setPricingEngine(shared_ptr[PricingEngine]&)
        T result[T](const string& tag)
