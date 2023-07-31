from quantlib.types cimport BigNatural, Integer, Real, Size
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.utilities.null cimport Null
cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.processes.heston_process cimport HestonProcess
cimport quantlib.processes._heston_process as _hp
from .mcvanillaengine cimport MCVanillaEngine
from . cimport _mceuropeanhestonengine as _mceh

cdef class MCEuropeanHestonEngine(MCVanillaEngine):

    def __init__(self, HestonProcess process, Size time_steps=Null[Integer](),
                 Size steps_per_year=Null[Integer](), bool antithetic_variate=True,
                 Size required_samples=Null[Integer](), Real required_tolerance=Null[Real](),
                 Size max_samples=Null[Integer](),
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
