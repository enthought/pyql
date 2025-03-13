"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from quantlib.types cimport BigNatural, Real, Size
from libcpp cimport bool

from quantlib.handle cimport shared_ptr
cimport quantlib._stochastic_process as _sp
from quantlib.pricingengines._pricing_engine cimport PricingEngine


cdef extern from 'ql/math/randomnumbers/rngtraits.hpp' namespace 'QuantLib' nogil:
    cdef cppclass PseudoRandom:
        pass
    cdef cppclass LowDiscrepancy:
        pass

cdef extern from 'ql/pricingengines/vanilla/mcvanillaengine.hpp' namespace 'QuantLib' nogil:
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
