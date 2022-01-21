from quantlib.handle cimport static_pointer_cast, shared_ptr
cimport quantlib.pricingengines.asian._analyticcontgeomavprice as _acgap
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
cimport quantlib.processes._black_scholes_process as _bsp


cdef class AnalyticContinuousGeometricAveragePriceAsianEngine(PricingEngine):
    """ Pricing engine for European continuous geometric average price Asian

    This class implements a continuous geometric average price Asian option
    with European exercise.  The formula is from [1]_.

    References
    ----------
    .. [1] E.G. Haug "Option Pricing Formulas", pp. 96-97, 1997
    """

    def __init__(self,  GeneralizedBlackScholesProcess process):
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)
        self._thisptr.reset(
            new _acgap.AnalyticContinuousGeometricAveragePriceAsianEngine(
                process_ptr))
