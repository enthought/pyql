include '../../types.pxi'

from libcpp cimport bool
from libcpp.string cimport string

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from quantlib.util.compat cimport py_compat_str_as_utf8_string

cimport quantlib.processes._heston_process as _hp
from quantlib.processes.heston_process cimport HestonProcess

from quantlib.pricingengines.engine cimport PricingEngine
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.pricingengines.vanilla._mcvanillaengine as _mc_ve

VALID_TRAITS = ['MCEuropeanHestonEngine',]
VALID_RNG = ['PseudoRandom',]

cdef class MCVanillaEngine(PricingEngine):

    def __init__(self, str trait, str RNG,
      HestonProcess process,
      doAntitheticVariate,
      Size stepsPerYear,
      Size requiredSamples,
      BigNatural seed):

        # validate inputs
        if trait not in VALID_TRAITS:
            raise ValueError('Traits must be in {}',format(VALID_TRAITS))

        if RNG not in VALID_RNG:
            raise ValueError(
                'RNG must be one of {}'.format(VALID_RNG)
            )

        # convert the Python str to C++ string
        cdef string traits_string = py_compat_str_as_utf8_string(trait)
        cdef string RNG_string = py_compat_str_as_utf8_string(RNG)

        # the input may be a Heston process or a Bates process
        # this may not be needed ...
        
        cdef shared_ptr[_hp.HestonProcess]* hp_pt = <shared_ptr[_hp.HestonProcess] *> process._thisptr

        cdef shared_ptr[_pe.PricingEngine] engine = _mc_ve.mc_vanilla_engine_factory(
          traits_string, 
          RNG_string,
          deref(<shared_ptr[_hp.HestonProcess]*> hp_pt),
          doAntitheticVariate,
          stepsPerYear,
          requiredSamples,
          seed)

        self._thisptr = new shared_ptr[_pe.PricingEngine](engine)

