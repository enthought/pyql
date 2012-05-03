include '../types.pxi'

from libcpp cimport bool

from _bonds cimport Instrument
from _payoffs cimport Payoff, StrikedTypePayoff
from _exercise cimport Exercise
from quantlib.handle cimport shared_ptr

cdef extern from 'ql/option.hpp' namespace 'QuantLib::Option':

    enum Type:
        Put 
        Call 

cdef extern from 'ql/option.hpp' namespace 'QuantLib':

    cdef cppclass Option(Instrument):

        shared_ptr[Payoff] payoff()
        shared_ptr[Exercise] exercise()

cdef extern from 'ql/instruments/oneassetoption.hpp' namespace 'QuantLib':

    cdef cppclass OneAssetOption(Option):
        OneAssetOption()
        OneAssetOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )

cdef extern from 'ql/instruments/vanillaoption.hpp' namespace 'QuantLib':

    cdef cppclass VanillaOption(OneAssetOption):
        VanillaOption()
        VanillaOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )

cdef extern from 'ql/instruments/europeanoption.hpp' namespace 'QuantLib':

    cdef cppclass EuropeanOption(VanillaOption):
        EuropeanOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )
