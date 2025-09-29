"""Two-factor additive Gaussian Model G2++"""
from quantlib.types cimport Real
from quantlib.handle cimport HandleYieldTermStructure
from . cimport _g2

cdef class G2(TwoFactorModel):
    r"""Two-factor additive gaussian model class.

    This class implements a two-additive-factor model defined by

    .. math::
       dr_t = \varphi(t) + x_t + y_t

    where :math:`x_t` and :math:`y_t` are defined by

    .. math::
       dx_t = -a x_t dt + \sigma dW^1_t, x_0 = 0\\
       dy_t = -b y_t dt + \sigma dW^2_t, y_0 = 0

    and :math:`dW^1_t dW^2_t = \rho dt`.
    """
    def __init(self,
               HandleYieldTermStructure h,
               Real a=0.1,
               Real sigma=0.01,
               Real b=0.1,
               Real eta=0.01,
               Real rho=-0.75):
        self._thisptr.reset(new _g2.G2(h.handle(), a, sigma, b, eta, rho))
