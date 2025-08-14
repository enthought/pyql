# Cython imports
from . cimport _option
from .exercise cimport Exercise
from .payoffs cimport Payoff

cdef class Option(Instrument):
    """base option class"""
    def __init__(self):
        raise NotImplementedError(
            'Cannot implement this abstract class. Use child like the '
            'VanillaOption'
        )

    Put = OptionType.Put
    Call = OptionType.Call

    def __str__(self):
        return '%s %s %s' % (
            type(self).__name__, str(self.exercise), str(self.payoff)
        )

    @property
    def exercise(self) -> Exercise:
        cdef Exercise ex = Exercise.__new__(Exercise)
        ex._thisptr = (<_option.Option*>self._thisptr.get()).exercise()
        return ex

    @property
    def payoff(self) -> Payoff:
        cdef Payoff po = Payoff.__new__(Payoff)
        po._thisptr = (<_option.Option*>self._thisptr.get()).payoff()
        return po
