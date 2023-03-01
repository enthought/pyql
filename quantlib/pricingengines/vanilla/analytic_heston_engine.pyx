from cython.operator cimport dereference as deref
from quantlib.types cimport Real, Size
from quantlib.models.equity.heston_model cimport HestonModel


cdef class Integration:

    @staticmethod
    def gaussLaguerre(Size integration_order=128):
        cdef Integration r = Integration.__new__(Integration)
        r.itg = new AHE.Integration(AHE.Integration.gaussLaguerre(integration_order))
        return r

    @staticmethod
    def gaussLegendre(Size integration_order=128):
        cdef Integration r = Integration.__new__(Integration)
        r.itg = new AHE.Integration(AHE.Integration.gaussLegendre(integration_order))
        return r

    @staticmethod
    def gaussChebyshev(Size integration_order=128):
        cdef Integration r = Integration.__new__(Integration)
        r.itg = new AHE.Integration(AHE.Integration.gaussChebyshev(integration_order))
        return r

    @staticmethod
    def gaussLobatto(Real rel_tolerance, Real abs_tolerance, Size max_evaluations=10000):
        cdef Integration r = Integration.__new__(Integration)
        r.itg = new AHE.Integration(AHE.Integration.gaussLobatto(rel_tolerance, abs_tolerance, max_evaluations))
        return r


    def __dealloc(self):
        del self.itg


cdef class AnalyticHestonEngine(PricingEngine):

    def __init__(self, HestonModel model, ComplexLogFormula cpx_log=ComplexLogFormula.Gatheral, Integration itg=Integration.gaussLaguerre(128), Real andersen_piterbarg_epsilon=1e-8):

        self._thisptr.reset(
            new AHE(model._thisptr, cpx_log, deref(itg.itg), andersen_piterbarg_epsilon)
        )
