include '../types.pxi'

from . cimport _black_scholes_process as _bsp
cimport quantlib._stochastic_process as _sp

from quantlib.handle cimport Handle, shared_ptr, dynamic_pointer_cast
cimport quantlib.termstructures.yields._flat_forward as _ff
from quantlib.quote cimport Quote
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure
cimport quantlib.termstructures.volatility.equityfx._black_vol_term_structure as _bvts
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure cimport BlackVolTermStructure


cdef class GeneralizedBlackScholesProcess(StochasticProcess1D):
    pass

cdef class BlackScholesProcess(GeneralizedBlackScholesProcess):

    def __init__(self, Quote x0 not None, YieldTermStructure risk_free_ts not None,
                 BlackVolTermStructure black_vol_ts not None):

        cdef Handle[_bvts.BlackVolTermStructure] black_vol_ts_handle = \
            Handle[_bvts.BlackVolTermStructure](
                dynamic_pointer_cast[_bvts.BlackVolTermStructure](black_vol_ts._thisptr)
            )

        self._thisptr = shared_ptr[_sp.StochasticProcess]( new \
            _bsp.BlackScholesProcess(
                x0.handle(),
                risk_free_ts._thisptr,
                black_vol_ts_handle
            )
        )

cdef class BlackScholesMertonProcess(GeneralizedBlackScholesProcess):

    def __init__(self,
                 Quote x0 not None,
                 YieldTermStructure dividend_ts not None,
                 YieldTermStructure risk_free_ts not None,
                 BlackVolTermStructure black_vol_ts not None):

        cdef Handle[_bvts.BlackVolTermStructure] black_vol_ts_handle = \
            Handle[_bvts.BlackVolTermStructure](
                dynamic_pointer_cast[_bvts.BlackVolTermStructure](black_vol_ts._thisptr)
            )

        self._thisptr = shared_ptr[_sp.StochasticProcess]( new \
            _bsp.BlackScholesMertonProcess(
                x0.handle(),
                dividend_ts._thisptr,
                risk_free_ts._thisptr,
                black_vol_ts_handle
            ))
