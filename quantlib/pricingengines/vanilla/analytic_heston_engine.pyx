cimport cython
from quantlib.types cimport Size
from quantlib.models.equity.heston_model cimport HestonModel

cdef class AnalyticHestonEngine(PricingEngine):

    def __init__(self, HestonModel model, Size integration_order=144):

        self._thisptr.reset(
            new AHE(model._thisptr, integration_order)
        )

cdef class Integration:
    @staticmethod
    def gaussLaguerre(Size integration_order=128):
        cdef Integration r = Integration.__new__(Integration)
        r.itg = new AHE.Integration(AHE.Integration.gaussLaguerre(integration_order))
        return r

    def __dealloc(self):
        del self.itg
