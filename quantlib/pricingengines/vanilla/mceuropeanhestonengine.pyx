include '../../types.pxi'
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
cimport quantlib.pricingengines._pricing_engine as _pe
from quantlib.processes.heston_process cimport HestonProcess
cimport quantlib.processes._heston_process as _hp
from .mcvanillaengine cimport MCVanillaEngine
cimport _mceuropeanhestonengine as _mceh

cdef class MCEuropeanHestonEngine(MCVanillaEngine):

    def __init__(self, HestonProcess process, Size time_steps,
                 Size steps_per_year, bool antithetic_variate,
                 Size required_samples, Real required_tolerance, Size max_samples,
                 BigNatural seed):
        self._thisptr = new shared_ptr[_pe.PricingEngine](
            new _mceh.MCEuropeanHestonEngine(
                static_pointer_cast[_hp.HestonProcess](process._thisptr),
                time_steps,
                steps_per_year,
                antithetic_variate,
                required_samples,
                required_tolerance,
                max_samples,
                seed))
