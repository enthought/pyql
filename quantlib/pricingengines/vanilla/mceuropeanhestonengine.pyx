from quantlib.types cimport BigNatural, Integer, Real, Size
from libcpp cimport bool
from quantlib._defines cimport QL_MAX_INTEGER
from quantlib.handle cimport static_pointer_cast
from quantlib.utilities.null cimport Null
from quantlib.processes.heston_process cimport HestonProcess
cimport quantlib.processes._heston_process as _hp
from . cimport _mceuropeanhestonengine as _mceh

cdef class MCEuropeanHestonEngine(MCVanillaEngine):

    def __init__(self, HestonProcess process, Size time_steps=Null[Size](),
                 Size steps_per_year=Null[Size](), bool antithetic_variate=True,
                 Size required_samples=Null[Integer](), Real required_tolerance=Null[Real](),
                 Size max_samples=QL_MAX_INTEGER,
                 BigNatural seed=0):
        self._thisptr.reset(
            new _mceh.MCEuropeanHestonEngine(
                static_pointer_cast[_hp.HestonProcess](process._thisptr),
                time_steps,
                steps_per_year,
                antithetic_variate,
                required_samples,
                required_tolerance,
                max_samples,
                seed))
