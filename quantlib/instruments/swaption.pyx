cimport _swaption
from quantlib.handle cimport shared_ptr, static_pointer_cast
from .option cimport Exercise
from .swap cimport VanillaSwap
cimport _vanillaswap
cimport _instrument

cpdef enum SettlementType:
    Physical
    Cash

cdef class Swaption(Instrument):
    def __init__(self, VanillaSwap swap not None, Exercise exercise not None,
                 SettlementType delivery=Physical):
        self._thisptr = shared_ptr[_instrument.Instrument](
            new _swaption.Swaption(
                static_pointer_cast[_vanillaswap.VanillaSwap](swap._thisptr),
                exercise._thisptr,
                <Settlement.Type>delivery))
