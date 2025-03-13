from quantlib.types cimport Real

from quantlib.handle cimport shared_ptr
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.time._date cimport Date
from libcpp.string cimport string
from libcpp cimport bool

cdef extern from 'ql/instrument.hpp' namespace 'QuantLib':
    cdef cppclass Instrument:
        Instrument()
        bool isExpired()
        Real NPV() except +
        Real errorEstimate() except +
        Date& valuationDate() except +
        void setPricingEngine(shared_ptr[PricingEngine]&)
        T result[T](const string& tag)
