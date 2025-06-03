include '../types.pxi'

from . cimport _black_scholes_process as _bsp
cimport quantlib._stochastic_process as _sp

from quantlib.quote cimport Quote
from quantlib.handle cimport HandleBlackVolTermStructure, HandleYieldTermStructure


cdef class GeneralizedBlackScholesProcess(StochasticProcess1D):
    pass

cdef class BlackScholesProcess(GeneralizedBlackScholesProcess):

    def __init__(self, Quote x0 not None, HandleYieldTermStructure risk_free_ts not None,
                 HandleBlackVolTermStructure black_vol_ts not None):

        self._thisptr.reset( new \
            _bsp.BlackScholesProcess(
                x0.handle(),
                risk_free_ts.handle(),
                black_vol_ts.handle()
            )
        )

cdef class BlackScholesMertonProcess(GeneralizedBlackScholesProcess):

    def __init__(self,
                 Quote x0 not None,
                 HandleYieldTermStructure dividend_ts not None,
                 HandleYieldTermStructure risk_free_ts not None,
                 HandleBlackVolTermStructure black_vol_ts not None):

        self._thisptr.reset( new \
            _bsp.BlackScholesMertonProcess(
                x0.handle(),
                dividend_ts.handle(),
                risk_free_ts.handle(),
                black_vol_ts.handle()
            )
        )
