include '../types.pxi'

# cython imports
cimport _option
cimport _payoffs

cdef extern from 'ql/option.hpp' namespace 'QuantLib::Option':

    enum Type:
        Put
        Call

PayOffTypeInWord = {Call:'Call', Put:'Put'}

cdef class Payoff:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __str__(self):
        return 'Payoff: %s' % self._thisptr.get().name().c_str()

cdef _payoffs.PlainVanillaPayoff* _get_payoff(PlainVanillaPayoff payoff):

    return <_payoffs.PlainVanillaPayoff*>payoff._thisptr.get()

cdef class PlainVanillaPayoff(Payoff):
    """

    PlainVanillaPayoff does not extend Payoff because of some issues
    casting shared_ptr[Payoff] to shared_ptr[PlainVanillPayoff] in
    quantlib.instruments.option
    """

    def __init__(self, option_type, float strike):

        self._thisptr = new shared_ptr[_payoffs.Payoff]( \
            new _payoffs.PlainVanillaPayoff(
                <_option.Type>option_type, <Real>strike
            )
        )

    def __str__(self):
        return 'Payoff: %s %s @ %f' % (
            self._thisptr.get().name().c_str(),
            PayOffTypeInWord[_get_payoff(self).optionType()],
            _get_payoff(self).strike()
        )

    property type:
        def __get__(self):
            return _get_payoff(self).optionType()

    property strike:
        def __get__(self):
            return _get_payoff(self).strike()

