from quantlib.instrument cimport Instrument

cdef extern from 'ql/option.hpp' namespace 'QuantLib::Option' nogil:
    cpdef enum class OptionType "QuantLib::Option::Type":
       """
       Attributes
       ----------
       Put
       Call
       """
       Put
       Call



cdef class Option(Instrument):
    pass
