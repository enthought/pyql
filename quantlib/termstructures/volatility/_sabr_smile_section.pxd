include "../../types.pxi"
from ._smilesection cimport SmileSection

cdef extern from 'ql/termstructures/volatility/sabrsmilesection.hpp' namespace 'QuantLib':
    cdef cppclass SabrSmileSection(SmileSection):
        pass
