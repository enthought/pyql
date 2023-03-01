from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle
from quantlib.pricingengines.vanilla.analytic_heston_engine cimport ComplexLogFormula, Integration
from quantlib.models.equity.heston_model cimport HestonModel
cimport quantlib.models.equity._heston_model as _hm
from . cimport _heston_black_vol_surface as _hbvs

cdef class HestonBlackVolSurface(BlackVolTermStructure):
    def __init__(self, HestonModel heston_model, ComplexLogFormula cplx_log_formula=ComplexLogFormula.Gatheral, Integration integration = Integration.gaussLaguerre(164)):
        self._thisptr.reset(new _hbvs.HestonBlackVolSurface(Handle[_hm.HestonModel](heston_model._thisptr), cplx_log_formula, deref(integration.itg)))
