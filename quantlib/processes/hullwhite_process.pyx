include '../types.pxi'

from cython.operator cimport dereference as deref
cimport _hullwhite_process as _hw

cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure

from quantlib.handle cimport Handle, shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff


cdef class HullWhiteProcess:
    """Hull-White process: a diffusion process for the short rate,
    with mean-reverting stochastic variance.

    .. math::
    dr_t &=& a(r_t-n) dt + \sigma dW^r_t \\

    """


    def __cinit__(self):
        pass

    def __dealloc(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __init__(self,
       YieldTermStructure risk_free_rate_ts,
       Real a,
       Real sigma):

        self._thisptr = new shared_ptr[_hw.HullWhiteProcess](
            new _hw.HullWhiteProcess(
                risk_free_rate_ts._thisptr,
                a, sigma))

    def __str__(self):
        return 'Hull-White process\na: %f sigma: %f' % \
          (self.a, self.sigma)


    property a:
        def __get__(self):
            return self._thisptr.get().a()

    property sigma:
        def __get__(self):
            return self._thisptr.get().sigma()
