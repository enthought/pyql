"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from cython.operator cimport dereference as deref
cimport _heston_process as _hp

from quantlib.handle cimport Handle, shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._quote as _qt
from quantlib.quotes cimport Quote, SimpleQuote
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure
from heston_process cimport HestonProcess

cdef class BatesProcess(HestonProcess):

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
       Real rho,
       Real lambda_,
       Real nu,
       Real delta
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
            new _hp.BatesProcess(
                risk_free_rate_ts_handle,
                dividend_ts_handle,
                s0_handle,
                v0, kappa, theta, sigma, rho,
                lambda_, nu, delta))

    def __str__(self):
        return 'Bates process\nv0: %f kappa: %f theta: %f sigma: %f\nrho: %f lambda: %f nu: %f delta: %f' % \
          (self.v0, self.kappa, self.theta, self.sigma,
           self.rho, self.Lambda, self.nu, self.delta)
    
    property Lambda:
        def __get__(self):
            return (<_hp.BatesProcess*> self._thisptr.get()).Lambda()
            
    property nu:
        def __get__(self):
            return (<_hp.BatesProcess*> self._thisptr.get()).nu()

    property delta:
        def __get__(self):
            return (<_hp.BatesProcess*> self._thisptr.get()).delta()
