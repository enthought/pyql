from quantlib.types cimport BigNatural, Integer, Real, Size
from libcpp cimport bool
from quantlib.handle cimport static_pointer_cast
from quantlib.utilities.null cimport Null
from quantlib.processes.hybrid_heston_hullwhite_process cimport HybridHestonHullWhiteProcess
cimport quantlib.processes._hybrid_heston_hullwhite_process as _hhwp
from quantlib._defines cimport QL_MAX_INTEGER
from . cimport _mchestonhullwhiteengine as _mchhw

cdef class MCHestonHullWhiteEngine(MCVanillaEngine):
    def __init__(self, HybridHestonHullWhiteProcess sp,
                 Size time_steps=Null[Size](),
                 Size time_steps_per_year=Null[Size](),
                 bool antithetic_variate=True,
                 bool control_variate=True,
                 Size required_samples=Null[Size](),
                 Real required_tolerance=Null[Real](),
                 Size max_samples=QL_MAX_INTEGER,
                 BigNatural seed=0):
        self._thisptr.reset(
            new _mchhw.MCHestonHullWhiteEngine(
                static_pointer_cast[_hhwp.HybridHestonHullWhiteProcess](sp._thisptr),
                time_steps,
                time_steps_per_year,
                antithetic_variate,
                control_variate,
                required_samples,
                required_tolerance,
                max_samples,
            seed)
        )
