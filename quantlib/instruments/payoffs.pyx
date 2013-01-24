include '../types.pxi'

# cython imports
cimport _option
cimport _payoffs

cdef public enum OptionType:
    Put = _option.Put
    Call = _option.Call


PAYOFF_TO_STR = {Call:'Call', Put:'Put'}

def str_to_option_type(name):
    if name.lower() == 'call':
        option_type = Call
    elif name.lower() == 'put':
        option_type = Put
    return option_type

cdef class Payoff:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __str__(self):
        if self._thisptr is not NULL:
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

    option_type: int or str
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

        if isinstance(option_type, basestring):
            option_type = str_to_option_type(option_type)
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
            PAYOFF_TO_STR[_get_payoff(self).optionType()],
            _get_payoff(self).strike()
        )

    property type:
        """ Exposes the internal option type.

        The type can be converted to str using the PAYOFF_TO_STR dictionnary.

        """
        def __get__(self):
            return _get_payoff(self).optionType()

    property strike:
        def __get__(self):
            return _get_payoff(self).strike()



