from quantlib.types cimport Real
from quantlib.handle cimport static_pointer_cast
from .hullwhite_process cimport HullWhiteForwardProcess
from .heston_process cimport HestonProcess
from . cimport _hullwhite_process as _hw
from . cimport _heston_process as _hp
from . cimport _hybrid_heston_hullwhite_process as _hhhwp

cdef class HybridHestonHullWhiteProcess(StochasticProcess):
    Euler = Discretization.Euler
    BSMHullWhite = Discretization.BSMHullWhite

    def __init__(self,
                 HestonProcess heston_process,
                 HullWhiteForwardProcess hull_white_process,
                 Real corr_equity_short_rate,
                 Discretization discretization=Discretization.BSMHullWhite):
        self._thisptr.reset(
            new _hhhwp.HybridHestonHullWhiteProcess(static_pointer_cast[_hp.HestonProcess](heston_process._thisptr),
                                                    static_pointer_cast[_hw.HullWhiteForwardProcess](hull_white_process._thisptr),
                                                    corr_equity_short_rate,
                                                    discretization)
        )
