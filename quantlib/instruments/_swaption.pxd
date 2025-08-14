include '../types.pxi'
from quantlib.handle cimport shared_ptr, optional
from ._fixedvsfloatingswap cimport FixedVsFloatingSwap 
from ._overnightindexedswap cimport OvernightIndexedSwap
from .._option cimport Option
from .._exercise cimport Exercise
from .swap cimport Type as SwapType
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.volatility.volatilitytype cimport VolatilityType
from quantlib.handle cimport Handle, optional
from .swaption cimport Type, Method

cdef extern from 'ql/instruments/swaption.hpp' namespace 'QuantLib':

    cdef cppclass Swaption(Option):
        Swaption(const shared_ptr[FixedVsFloatingSwap]& swap,
                 const shared_ptr[Exercise]& exercise,
                 Type delivery, # = Settlement::Physical
                 Method settlementMethod) # Settlement::PhysicalOTC
        Type settlementType()
        Method settlementMethod()
        Volatility impliedVolatility(Real price,
                                     const Handle[YieldTermStructure]& discountCurve,
                                     Volatility guess,
                                     Real accuracy,# = 1.0e-4,
                                     Natural maxEvaluations,# = 100,
                                     Volatility minVol,# = 1.0e-7,
                                     Volatility maxVol,# = 4.0,
                                     VolatilityType type,# = ShiftedLognormal,
                                     Real displacement)# = 0.0)
        SwapType type() const
        const shared_ptr[FixedVsFloatingSwap]& underlying()
