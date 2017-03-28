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
cimport quantlib.processes._stochastic_process as _sp
from quantlib.pricingengines._pricing_engine cimport PricingEngine


cdef extern from 'ql/math/randomnumbers/rngtraits.hpp' namespace 'QuantLib':
    cdef cppclass PseudoRandom:
        pass
    cdef cppclass LowDiscrepancy:
        pass

cdef extern from 'ql/methods/montecarlo/mctraits.hpp' namespace 'QuantLib':
    cdef cppclass MultiVariate:
        pass
    cdef cppclass SingleVariate:
        pass

cdef extern from 'ql/pricingengines/vanilla/mcvanillaengine.hpp' namespace 'QuantLib':
    cdef cppclass MCVanillaEngine[MC, RNG, S=*, INST=*](PricingEngine):
        MCVanillaEngine(shared_ptr[_sp.StochasticProcess]& sp,
                        Size timeSteps,
                        Size timeStepsPerYear,
                        bool brownianBridge,
                        bool anitheticVariate,
                        bool controlVariate,
                        Size requiredSamples,
                        Real requiredTolerance,
                        Size maxSamples,
                        BigNatural seed)
