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
       YieldTermStructure risk_free_rate_ts,
       YieldTermStructure dividend_ts,
       Quote s0,
       Real v0,
       Real kappa,
       Real theta,
       Real sigma,
       Real rho
    ):

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


    def size(self):
        return self._thisptr.get().size()

    def v0(self):
        return self._thisptr.get().v0()

    def rho(self):
        return self._thisptr.get().rho()

    def kappa(self):
        return self._thisptr.get().kappa()

    def theta(self):
        return self._thisptr.get().theta()

    def sigma(self):
        return self._thisptr.get().sigma()

    def s0(self):
        #cdef _hp.HestonProcess* hp_ptr = self._thisptr.get()
        cdef Handle[_qt.Quote] handle = self._thisptr.get().s0()
        cdef shared_ptr[_qt.Quote] quote_sptr = shared_ptr[_qt.Quote](handle.currentLink())

        # maybe not optmal but easiest to do
        return  SimpleQuote(quote_sptr.get().value())

