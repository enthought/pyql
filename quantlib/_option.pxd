from ._instrument cimport Instrument
from ._exercise cimport Exercise
from ._payoffs cimport Payoff
from quantlib.handle cimport shared_ptr


cdef extern from 'ql/option.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Option(Instrument):
        shared_ptr[Payoff] payoff()
        shared_ptr[Exercise] exercise()
