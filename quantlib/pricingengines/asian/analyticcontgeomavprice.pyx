from cython.operator cimport dereference as deref

from quantlib.handle cimport static_pointer_cast, shared_ptr
from quantlib.pricingengines._pricing_engine cimport PricingEngine as QlPricingEngine
cimport quantlib.pricingengines.asian._analyticcontgeomavprice as _acgap
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
cimport quantlib.processes._black_scholes_process as _bsp


cdef class AnalyticContinuousGeometricAveragePriceAsianEngine(PricingEngine):
    """ Pricing engine for European continuous geometric average price Asian
     This class implements a continuous geometric average price
        Asian option with European exercise.  The formula is from
        "Option Pricing Formulas", E. G. Haug (1997) pag 96-97.
       ingroup asianengines
        test
        - the correctness of the returned value is tested by
          reproducing results available in literature, and results
          obtained using a discrete average approximation.
        - the correctness of the returned greeks is tested by
          reproducing numerical derivatives.
       TODO: handle seasoned options
    """
    
    def __init__(self,  GeneralizedBlackScholesProcess process):
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)
        self._thisptr.reset(
            new _acgap.AnalyticContinuousGeometricAveragePriceAsianEngine(
                process_ptr))
    
