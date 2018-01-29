include '../types.pxi'

# cython imports
cimport _option

import six

cdef public enum OptionType:
    Put = _option.Put
    Call = _option.Call


PAYOFF_TO_STR = {Call: 'Call', Put: 'Put'}

cdef class Payoff:

    def __str__(self):
        if self._thisptr:
            return 'Payoff: %s' % self._thisptr.get().name().decode('utf-8')

cdef inline _payoffs.PlainVanillaPayoff* _get_payoff(PlainVanillaPayoff payoff):
    return <_payoffs.PlainVanillaPayoff*> payoff._thisptr.get()

cdef class PlainVanillaPayoff(Payoff):
    """ Plain vanilla payoff.

    Parameters
    ----------

    option_type: int or str
        The type of option, can be either Call or Put
    strike: double
        The strike value

    Properties
    ----------
    exercise: Exercise
        Read-only property that returns an Exercise instance
    payoff: PlainVanilaPayoff
        Read-only property that returns a PlainVanillaPayoff instance
    """

    def __init__(self, OptionType option_type, double strike):

        self._thisptr = shared_ptr[_payoffs.Payoff](
            new _payoffs.PlainVanillaPayoff(
                <_option.Type>option_type, <Real>strike
            )
        )



    def __str__(self):

        return 'Payoff: %s %s @ %f' % (
            _get_payoff(self).name().decode('utf-8'),
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
