from quantlib.types cimport Real, Time

from quantlib.ext cimport static_pointer_cast
from . cimport _twofactor_model as _tfm
cimport quantlib._stochastic_process as _sp
from quantlib.stochastic_process cimport StochasticProcess1D

cdef class ShortRateDynamics:
    r"""Class describing the dynamics of the two state variables

    We assume here that the short-rate is a function of two state
    variables :math:`x` and :math:`y`.

    .. math::
            r_t = f(t, x_t, y_t)
    of two state variables :math:`x_t` and :math:`y_t`. These stochastic
    processes satisfy

    .. math::
            x_t = \mu_x(t, x_t)dt + \sigma_x(t, x_t) dW_t^x\\
            y_t = \mu_y(t,y_t)dt + \sigma_y(t, y_t) dW_t^y

    where :math:`W^x` and :math:`W^y` are two brownian motions satisfying

    .. math::
            dW^x_t dW^y_t = \rho dt
    """

    @property
    def x_process(self):
        """Risk-neutral dynamics of the first state variable x"""
        cdef StochasticProcess1D sp = StochasticProcess1D.__new__(StochasticProcess1D)
        sp._thisptr = static_pointer_cast[_sp.StochasticProcess](self._thisptr.get().xProcess())
        return sp

    @property
    def y_process(self):
        """Risk-neutral dynamics of the second state variable y"""
        cdef StochasticProcess1D sp = StochasticProcess1D.__new__(StochasticProcess1D)
        sp._thisptr = static_pointer_cast[_sp.StochasticProcess](self._thisptr.get().yProcess())
        return sp

    def short_rate(self, Time t, Real x, Real y):
        return self._thisptr.get().shortRate(t, x, y)

    @property
    def correlation(self):
        """Correlation :math:`\\rho` between the two brownian motions"""
        return self._thisptr.get().correlation()

cdef class TwoFactorModel(ShortRateModel):

    @property
    def dynamics(self):
        """short-rate dynamics

        Returns
        -------
        dynamics : :class:`~quantlib.models.shortrate.twofactor_model.ShortRateDynamics`
        """
        cdef ShortRateDynamics dyn = ShortRateDynamics.__new__(ShortRateDynamics)
        dyn._thisptr =  (<_tfm.TwoFactorModel*>self._thisptr.get()).dynamics()
        return dyn
