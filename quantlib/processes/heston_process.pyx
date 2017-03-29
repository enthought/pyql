include '../types.pxi'

from cython.operator cimport dereference as deref
cimport _heston_process as _hp
cimport quantlib._stochastic_process as _sp

cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

from quantlib.handle cimport Handle, shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._quote as _qt
from quantlib.quotes cimport Quote, SimpleQuote

cdef public enum Discretization:
        PARTIALTRUNCATION = _hp.PartialTruncation
        FULLTRUNCATION = _hp.FullTruncation
        REFLECTION = _hp.Reflection
        NONCENTRALCHISQUAREVARIANCE = _hp.NonCentralChiSquareVariance
        QUADRATICEXPONENTIAL = _hp.QuadraticExponential
        QUADRATICEXPONENTIALMARTINGALE = _hp.QuadraticExponentialMartingale

cdef class HestonProcess(StochasticProcess):
    r"""
    Heston process: a diffusion process with mean-reverting stochastic variance.

    .. math::

        dS_t =& (r-d) S_t dt + \sqrt{V_t} S_t dW^s_t \\
        dV_t =& \kappa (\theta - V_t) dt + \varepsilon \sqrt{V_t} dW^\upsilon_t \\
        dW^s_t dW^\upsilon_t =& \rho dt

    """

    def __cinit__(self):
        pass

    def __init__(self,
       YieldTermStructure risk_free_rate_ts=YieldTermStructure(),
       YieldTermStructure dividend_ts=YieldTermStructure(),
       Quote s0=SimpleQuote(),
       Real v0=0,
       Real kappa=0,
       Real theta=0,
       Real sigma=0,
       Real rho=0,
       Discretization d=QUADRATICEXPONENTIALMARTINGALE):

        #create handles
        cdef Handle[_qt.Quote] s0_handle = Handle[_qt.Quote](deref(s0._thisptr))

        self._thisptr = shared_ptr[_sp.StochasticProcess](
            new _hp.HestonProcess(
                risk_free_rate_ts._thisptr,
                dividend_ts._thisptr,
                s0_handle,
                v0, kappa, theta, sigma, rho, d
            )
        )

    def __str__(self):
        return 'Heston process\nv0: %f kappa: %f theta: %f sigma: %f rho: %f' % \
          (self.v0, self.kappa, self.theta, self.sigma, self.rho)



    property v0:
        def __get__(self):
            return (<_hp.HestonProcess*>self._thisptr.get()).v0()

    property rho:
        def __get__(self):
            return (<_hp.HestonProcess*>self._thisptr.get()).rho()

    property kappa:
        def __get__(self):
            return (<_hp.HestonProcess*>self._thisptr.get()).kappa()

    property theta:
        def __get__(self):
            return (<_hp.HestonProcess*>self._thisptr.get()).theta()

    property sigma:
        def __get__(self):
            return (<_hp.HestonProcess*>self._thisptr.get()).sigma()

    @property
    def s0(self):
        cdef Handle[_qt.Quote] handle = (<_hp.HestonProcess*>self._thisptr.get()).s0()
        cdef SimpleQuote q = SimpleQuote.__new__(SimpleQuote)
        q._thisptr = new shared_ptr[_qt.Quote](handle.currentLink())
        return q
