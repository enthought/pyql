# distutils: language = c++

from quantlib.handle cimport shared_ptr
cimport _pricing_engine as _pe
from engine cimport PricingEngine

cdef class MiPointCdsEngine(PricingEngine):

    def __init__(self): #, PiecewiseDefaultCurve ts, float recovery_rate,
                 #YieldTermStructure discount_curve):
        """
        First argument should be a DefaultProbabilityTermStructure. I am using
        the PiecewiseDefaultCurve at the moment.

        """

        self._thisptr = new shared_ptr[_pe.PricingEngine](
            #new _credit.MidPointCdsEngine()
        )
