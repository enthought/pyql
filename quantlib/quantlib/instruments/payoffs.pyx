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
            print 'Payoff deallocated'
            del self._thisptr

    def __str__(self):
        return 'Payoff: %s' % self._thisptr.get().name().c_str()

cdef class PlainVanillaPayoff:
    """

    PlainVanillaPayoff does not extend Payoff because of some issues
    casting shared_ptr[Payoff] to shared_ptr[PlainVanillPayoff] in
    quantlib.instruments.option
    """

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            print 'Payoff deallocated'
            del self._thisptr

    def __init__(self, option_type, float strike):

        self._thisptr = new shared_ptr[_payoffs.StrikedTypePayoff]( \
            new _payoffs.PlainVanillaPayoff(
                <_option.Type>option_type, <Real>strike
            )
        )

    def __str__(self):
        return 'Payoff: %s %s @ %f' % (
            self._thisptr.get().name().c_str(),
            PayOffTypeInWord[
                (<_payoffs.TypePayoff*> self._thisptr.get()).optionType()
            ],
            (<_payoffs.StrikedTypePayoff*> self._thisptr.get()).strike())

    property type:
        def __get__(self):
            return self._thisptr.get().optionType()

    property strike:
        def __get__(self):
            return self._thisptr.get().strike()

