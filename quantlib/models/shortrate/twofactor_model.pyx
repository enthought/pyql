from quantlib.types cimport Real, Time

from quantlib.handle cimport static_pointer_cast
from . cimport _twofactor_model as _tfm
cimport quantlib._stochastic_process as _sp
from quantlib.stochastic_process cimport StochasticProcess1D

cdef class ShortRateDynamics:

    @property
    def process_x(self):
        cdef StochasticProcess1D sp = StochasticProcess1D.__new__(StochasticProcess1D)
        sp._thisptr = static_pointer_cast[_sp.StochasticProcess](self._thisptr.get().xProcess())
        return sp

    @property
    def process_x(self):
        cdef StochasticProcess1D sp = StochasticProcess1D.__new__(StochasticProcess1D)
        sp._thisptr = static_pointer_cast[_sp.StochasticProcess](self._thisptr.get().yProcess())
        return sp

    def short_rate(self, Time t, Real x, Real y):
        return self._thisptr.get().shortRate(t, x, y)

cdef class TwoFactorModel(ShortRateModel):

    @property
    def dynamics(self):
        cdef ShortRateDynamics dyn = ShortRateDynamics.__new__(ShortRateDynamics)
        dyn._thisptr =  (<_tfm.TwoFactorModel*>self._thisptr.get()).dynamics()
        return dyn
