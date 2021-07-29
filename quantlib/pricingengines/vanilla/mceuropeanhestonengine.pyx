include '../../types.pxi'
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib._defines cimport QL_NULL_INTEGER, QL_NULL_REAL
cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.processes.heston_process cimport HestonProcess
cimport quantlib.processes._heston_process as _hp
from .mcvanillaengine cimport MCVanillaEngine
from . cimport _mceuropeanhestonengine as _mceh

cdef class MCEuropeanHestonEngine(MCVanillaEngine):

    def __init__(self, HestonProcess process, Size time_steps=QL_NULL_INTEGER,
                 Size steps_per_year=QL_NULL_INTEGER, bool antithetic_variate=True,
                 Size required_samples=QL_NULL_INTEGER, Real required_tolerance=QL_NULL_REAL,
                 Size max_samples=QL_NULL_INTEGER,
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
