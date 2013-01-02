include '../types.pxi'

from cython.operator cimport dereference as deref
cimport _heston_process as _hp

from quantlib.handle cimport Handle, shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._quote as _qt
from quantlib.quotes cimport Quote, SimpleQuote
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure

cdef class HestonProcess:

    def __cinit__(self):
        pass

    def __dealloc(self):
        pass

    def __init__(self,
       YieldTermStructure risk_free_rate_ts=None,
       YieldTermStructure dividend_ts=None,
       Quote s0=None,
       Real v0=0,
       Real kappa=0,
       Real theta=0,
       Real sigma=0,
       Real rho=0
    ):

        self._thisptr = NULL

        if s0 is None:
            return
        
        #create handles
        cdef Handle[_qt.Quote] s0_handle = Handle[_qt.Quote](deref(s0._thisptr))
        cdef Handle[_ff.YieldTermStructure] dividend_ts_handle = \
                Handle[_ff.YieldTermStructure](
                    deref(dividend_ts._thisptr)
                )
        cdef Handle[_ff.YieldTermStructure] risk_free_rate_ts_handle = \
                Handle[_ff.YieldTermStructure](
                    deref(risk_free_rate_ts._thisptr)
                )

        self._thisptr = new shared_ptr[_hp.HestonProcess](
            new _hp.HestonProcess(
                risk_free_rate_ts_handle,
                dividend_ts_handle,
                s0_handle,
                v0, kappa, theta, sigma, rho
            )
        )

    def __str__(self):
        return 'Heston process\nv0: %f kappa: %f theta: %f sigma: %f rho: %f' % \
          (self.v0, self.kappa, self.theta, self.sigma, self.rho)


    def size(self):
        return self._thisptr.get().size()

    property v0:
        def __get__(self):
            return self._thisptr.get().v0()

    property rho:
        def __get__(self):
            return self._thisptr.get().rho()

    property kappa:
        def __get__(self):
            return self._thisptr.get().kappa()

    property theta:
        def __get__(self):
            return self._thisptr.get().theta()

    property sigma:
        def __get__(self):
            return self._thisptr.get().sigma()

    def s0(self):
        #cdef _hp.HestonProcess* hp_ptr = self._thisptr.get()
        cdef Handle[_qt.Quote] handle = self._thisptr.get().s0()
        cdef shared_ptr[_qt.Quote] quote_sptr = shared_ptr[_qt.Quote](handle.currentLink())

        # maybe not optmal but easiest to do
        return  SimpleQuote(quote_sptr.get().value())

