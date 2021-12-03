"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from cython.operator cimport dereference as deref
cimport quantlib._stochastic_process as _sp
from ._heston_process cimport BatesProcess as QlBatesProcess
from .heston_process cimport HestonProcess, Discretization, FullTruncation

from quantlib.handle cimport shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff
from quantlib.quote cimport Quote
from quantlib.quotes.simplequote cimport SimpleQuote
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure

cdef class BatesProcess(HestonProcess):

    def __init__(self,
       YieldTermStructure risk_free_rate_ts=YieldTermStructure(),
       YieldTermStructure dividend_ts=YieldTermStructure(),
       Quote s0=SimpleQuote(),
       Real v0=0,
       Real kappa=0,
       Real theta=0,
       Real sigma=0,
       Real rho=0,
       Real lambda_=0,
       Real nu=0,
       Real delta=0,
       Discretization d=FullTruncation):

        self._thisptr = shared_ptr[_sp.StochasticProcess](
            new QlBatesProcess(
                risk_free_rate_ts._thisptr,
                dividend_ts._thisptr,
                s0.handle(),
                v0, kappa, theta, sigma, rho,
                lambda_, nu, delta, d))

    def __str__(self):
        return 'Bates process\nv0: %f kappa: %f theta: %f sigma: %f\nrho: %f lambda: %f nu: %f delta: %f' % \
          (self.v0, self.kappa, self.theta, self.sigma,
           self.rho, self.Lambda, self.nu, self.delta)

    property Lambda:
        def __get__(self):
            return (<QlBatesProcess*> self._thisptr.get()).Lambda()

    property nu:
        def __get__(self):
            return (<QlBatesProcess*> self._thisptr.get()).nu()

    property delta:
        def __get__(self):
            return (<QlBatesProcess*> self._thisptr.get()).delta()
