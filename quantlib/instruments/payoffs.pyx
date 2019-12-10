include '../types.pxi'
from cython.operator import dereference as deref

# cython imports
from . cimport _option

cdef class Payoff:

    def __repr__(self):
        if self._thisptr.get():
            return self._thisptr.get().description().decode('utf-8')

    def __str__(self):
        if self._thisptr.get():
            return self._thisptr.get().name().decode('utf-8')

    def __call__(self, Real price):
        return deref(self._thisptr)(price)

cdef inline _payoffs.PlainVanillaPayoff* _get_payoff(PlainVanillaPayoff payoff):
    return <_payoffs.PlainVanillaPayoff*> payoff._thisptr.get()

cdef class PlainVanillaPayoff(Payoff):
    """ Plain vanilla payoff.

    Parameters
    ----------

    option_type: int
        The type of option, can be either Call or Put
    strike: double
        The strike value

    Properties
    ----------
    option_type: Call or Put
    strike: float
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
