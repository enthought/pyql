from quantlib.termstructures._helpers cimport BootstrapHelper
from quantlib.termstructures._inflation_term_structure \
    cimport ZeroInflationTermStructure, YoYInflationTermStructure

cdef extern from 'ql/termstructures/inflation/inflationtraits.hpp' namespace 'QuantLib':
    cdef cppclass ZeroInflationTraits:
        ctypedef BootstrapHelper[ZeroInflationTermStructure] helper

    cdef cppclass YoYInflationTraits:
        ctypedef BootstrapHelper[YoYInflationTermStructure] helper
