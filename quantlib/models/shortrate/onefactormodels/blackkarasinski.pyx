"""Black-Karasinski model"""

from quantlib.types cimport Real
cimport quantlib.models._model as _mo
from . cimport _blackkarasinski as _bk
from quantlib.handle cimport shared_ptr
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cdef class BlackKarasinski(OneFactorModel):
    r"""Standard Black-Karasinski model

     defined by

     .. math::
        d\ln r_t = (\theta(t) - \alpha \ln r_t)dt + \sigma dW_t,

     where :math:`alpha` and :math:`\sigma` are constants.
    """

    def __init__(self,
       YieldTermStructure term_structure,
       Real a=0.1,
       Real sigma=0.1):

        self._thisptr = shared_ptr[_mo.CalibratedModel](
            new _bk.BlackKarasinski(
                term_structure._thisptr, a, sigma
	    )
	)
