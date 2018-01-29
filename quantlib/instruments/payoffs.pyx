include '../types.pxi'

# cython imports
cimport _option

import six

cdef class Payoff:

    def __str__(self):
        if self._thisptr.get():
            return self._thisptr.get().description().decode('utf-8')

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

    def __init__(self, _option.Type option_type, double strike):

        self._thisptr = shared_ptr[_payoffs.Payoff](
            new _payoffs.PlainVanillaPayoff(
                option_type, <Real>strike
            )
        )



    property option_type:
        """ Exposes the internal option type.

        The type can be converted to str using the OptionType enum.

        """
        def __get__(self):
            return _get_payoff(self).optionType()

    property strike:
        def __get__(self):
            return _get_payoff(self).strike()
