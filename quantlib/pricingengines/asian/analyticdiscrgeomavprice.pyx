from cython.operator cimport dereference as deref

from quantlib.handle cimport static_pointer_cast, shared_ptr
from quantlib.pricingengines._pricing_engine cimport PricingEngine as QlPricingEngine
cimport quantlib.pricingengines.asian._analyticdiscrgeomavprice as _adgap
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
cimport quantlib.processes._black_scholes_process as _bsp


cdef class AnalyticDiscreteGeometricAveragePriceAsianEngine(PricingEngine):
    """ Pricing engine for European discrete geometric average price Asian option

        This class implements a discrete geometric average price Asian
        option, with European exercise.  The formula is from "Asian
        Option", E. Levy (1997) in "Exotic Options: The State of the
        Art", edited by L. Clewlow, C. Strickland, pag 65-97
        TODO implement correct theta, rho, and dividend-rho calculation
        test
        - the correctness of the returned value is tested by
          reproducing results available in literature.
        - the correctness of the available greeks is tested against
          numerical calculations
    """
    
    def __init__(self,  GeneralizedBlackScholesProcess process):
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)
        self._thisptr.reset(
            new _adgap.AnalyticDiscreteGeometricAveragePriceAsianEngine(
                process_ptr))
    
