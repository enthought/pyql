from quantlib.instrument cimport Instrument
from . cimport _option

cdef extern from 'ql/option.hpp' namespace 'QuantLib::Option':
    cpdef enum class OptionType "QuantLib::Option::Type":
        Put
        Call



cdef class Option(Instrument):
    pass

cdef class OneAssetOption(Option):
    cdef inline _option.OneAssetOption* as_ptr(self) nogil
