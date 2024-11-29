from quantlib.types cimport Real
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _g2

cdef class G2(TwoFactorModel):
    def __init(self,
               HandleYieldTermStructure h,
               Real a=0.1,
               Real sigma=0.01,
               Real b=0.1,
               Real eta=0.01,
               Real rho=-0.75):
        self._thisptr.reset(new _g2.G2(h.handle, a, sigma, b, eta, rho))
