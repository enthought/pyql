""" European option on a single asset """
from . cimport _europeanoption as _eo
from ..payoffs cimport StrikedTypePayoff
from ..exercise cimport Exercise
from .. cimport _payoffs
from quantlib.handle cimport shared_ptr, static_pointer_cast

cdef class EuropeanOption(VanillaOption):
    """European option on a single asset"""
    def __init__(self, StrikedTypePayoff payoff not None, Exercise exercise not None):

        cdef shared_ptr[_payoffs.StrikedTypePayoff] payoff_ptr = \
            static_pointer_cast[_payoffs.StrikedTypePayoff](
                payoff._thisptr)

        self._thisptr.reset(
            new _eo.EuropeanOption(payoff_ptr, exercise._thisptr)
        )
