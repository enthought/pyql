include 'types.pxi'
from cython.operator import dereference as deref

# cython imports
from .option cimport OptionType

cdef inline _payoffs.PlainVanillaPayoff* _get_payoff(PlainVanillaPayoff payoff):
    return <_payoffs.PlainVanillaPayoff*> payoff._thisptr.get()

cdef class Payoff:

    def __repr__(self):
        if self._thisptr:
            return self._thisptr.get().description().decode('utf-8')
        else:
            raise ValueError("Abstract Payoff")

    def __str__(self):
        if self._thisptr:
            return self._thisptr.get().name().decode('utf-8')

    def __call__(self, Real price):
        return deref(self._thisptr)(price)


cdef class StrikedTypePayoff(Payoff):
    pass


cdef class PlainVanillaPayoff(StrikedTypePayoff):
    """ Plain vanilla payoff.

    Parameters
    ----------

    option_type: :class:`~quantlib.option.OptionType`
        The type of option, can be either `Call` or `Put`
    strike: double
        The strike value

    """

    def __init__(self, OptionType option_type, double strike):

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
