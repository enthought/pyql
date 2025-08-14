from quantlib.instrument cimport Instrument

cdef extern from 'ql/option.hpp' namespace 'QuantLib::Option':
    cpdef enum class OptionType "QuantLib::Option::Type":
        Put
        Call



cdef class Option(Instrument):
    pass
