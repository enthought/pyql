from ._black_vol_term_structure cimport BlackVolTermStructure
from quantlib.pricingengines.vanilla._analytic_heston_engine cimport AnalyticHestonEngine
from quantlib.handle cimport Handle
from quantlib.models.equity._heston_model cimport HestonModel

cdef extern from 'ql/termstructures/volatility/equityfx/hestonblackvolsurface.hpp' namespace 'QuantLib' nogil:

    cdef cppclass HestonBlackVolSurface(BlackVolTermStructure):
        HestonBlackVolSurface(const Handle[HestonModel]& hestonModel,
                              AnalyticHestonEngine.ComplexLogFormula cplxLogFormula, # = AnalyticHestonEngine::Gatheral
                              AnalyticHestonEngine.Integration integration) # = AnalyticHestonEngine::Integration::gaussLaguerre(164)
