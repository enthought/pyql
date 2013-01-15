"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool

from quantlib.handle cimport shared_ptr
cimport quantlib.processes._heston_process as _hp
cimport quantlib.pricingengines._pricing_engine as _pe

cdef extern from 'mc_vanilla_engine_support_code.hpp' namespace 'QuantLib':

    cdef shared_ptr[_pe.PricingEngine] mc_vanilla_engine_factory(
      string& trait, 
      string& RNG,
      shared_ptr[_hp.HestonProcess]& process,
      bool doAntitheticVariate,
      Size stepsPerYear,
      Size requiredSamples,
      BigNatural seed) except +

## Cython does not seem to handle nested templates
## cdef extern from 'ql/pricingengines/vanilla/mcvanillaengine.hpp' namespace 'QuantLib':

##     cdef cppclass MCVanillaEngine[[MC], RNG, S, Inst]:
##         pass
##         # Not using the constructor because of the missing support for typemaps
##         # in Cython --> use only the vanilla_engine_factory!

