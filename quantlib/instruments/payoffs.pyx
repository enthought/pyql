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

    cdef set_payoff(self, shared_ptr[_payoffs.Payoff] payoff):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL
        if payoff.get() == NULL:
            raise ValueError('Setting the payoff with a null pointer.')
        self._thisptr = new shared_ptr[_payoffs.Payoff](payoff)

cdef _payoffs.PlainVanillaPayoff* _get_payoff(PlainVanillaPayoff payoff):

    return <_payoffs.PlainVanillaPayoff*>payoff._thisptr.get()

cdef class PlainVanillaPayoff(Payoff):
    """ Plain vanilla payoff.

    Parameters
    ----------

    option_type: int
        The type of option, can be either Call or Put
    strike: float
        The strike value
    from_qlpayoff: bool, optional
        For internal use only

    Properties
    ----------
    exercise: Exercise
        Read-only property that returns an Exercise instance
    payoff: PlainVanilaPayoff
        Read-only property that returns a PlainVanillaPayoff instance
    """

    def __init__(self, option_type, float strike, from_qlpayoff=False):

        if not from_qlpayoff:
            self._thisptr = new shared_ptr[_payoffs.Payoff]( \
                new _payoffs.PlainVanillaPayoff(
                    <_option.Type>option_type, <Real>strike
                )
            )
        else:
            # instance is created based on a cpp QuantLib payoff
            # user is supposed to call the set_payoff method afterwards.
            # This can be dangerous as we use an instance with a NULL ptr ...
            pass

    def __str__(self):
        return 'Payoff: %s %s @ %f' % (
            _get_payoff(self).name().c_str(),
            PayOffTypeInWord[_get_payoff(self).optionType()],
            _get_payoff(self).strike()
        )

    property type:
        def __get__(self):
            return _get_payoff(self).optionType()

    property strike:
        def __get__(self):
            return _get_payoff(self).strike()



