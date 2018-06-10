include '../types.pxi'
from quantlib.handle cimport shared_ptr
from ._vanillaswap cimport VanillaSwap
from ._option cimport Option
from ._exercise cimport Exercise
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.volatility._volatilitytype cimport VolatilityType
from quantlib.handle cimport Handle

cdef extern from 'ql/instruments/swaption.hpp' namespace 'QuantLib':
    cdef cppclass Settlement:
        enum Type:
            Physical
            Cash

    cdef cppclass Swaption(Option):
        Swaption(const shared_ptr[VanillaSwap]& swap,
                 const shared_ptr[Exercise]& exercise,
                 Settlement.Type delivery)# = Settlement.Physical)
        Settlement.Type settlementType()
        Volatility impliedVolatility(Real price,
                                     const Handle[YieldTermStructure]& discountCurve,
                                     Volatility guess,
                                     Real accuracy,# = 1.0e-4,
                                     Natural maxEvaluations,# = 100,
                                     Volatility minVol,# = 1.0e-7,
                                     Volatility maxVol,# = 4.0,
                                     VolatilityType type,# = ShiftedLognormal,
                                     Real displacement)# = 0.0)
        const shared_ptr[VanillaSwap]& underlyingSwap()
