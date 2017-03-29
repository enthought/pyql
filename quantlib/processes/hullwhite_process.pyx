include '../types.pxi'

from cython.operator cimport dereference as deref
cimport _hullwhite_process as _hw
cimport quantlib._stochastic_process as _sp
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
cimport quantlib.termstructures.yields._flat_forward as _ff


cdef class HullWhiteProcess(StochasticProcess1D):
    """Hull-White process: a diffusion process for the short rate,
    with mean-reverting stochastic variance.

    .. math::
    dr_t &=& a(r_t-n) dt + \sigma dW^r_t \\

    """

    def __init__(self,
       YieldTermStructure risk_free_rate_ts,
       Real a,
       Real sigma):

        self._thisptr = shared_ptr[_sp.StochasticProcess](
            new _hw.HullWhiteProcess(
                risk_free_rate_ts._thisptr,
                a, sigma))

    def __str__(self):
        return 'Hull-White process\na: %f sigma: %f' % \
          (self.a, self.sigma)

    @property
    def a(self):
        return static_pointer_cast[_hw.HullWhiteProcess](self._thisptr).get().a()

    @property
    def sigma(self):
        return static_pointer_cast[_hw.HullWhiteProcess](self._thisptr).get().sigma()
