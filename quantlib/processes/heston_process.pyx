include '../types.pxi'

from .heston_process cimport PartialTruncation
cimport quantlib._stochastic_process as _sp

cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

from quantlib.handle cimport Handle, shared_ptr
cimport quantlib._quote as _qt
from quantlib.quote cimport Quote
from quantlib.quotes.simplequote cimport SimpleQuote

cdef class HestonProcess(StochasticProcess):
    r"""
    Heston process: a diffusion process with mean-reverting stochastic variance.

    .. math::

        dS_t =& (r-d) S_t dt + \sqrt{V_t} S_t dW^s_t \\
        dV_t =& \kappa (\theta - V_t) dt + \varepsilon \sqrt{V_t} dW^\upsilon_t \\
        dW^s_t dW^\upsilon_t =& \rho dt

    """

    def __init__(self,
       YieldTermStructure risk_free_rate_ts=YieldTermStructure(),
       YieldTermStructure dividend_ts=YieldTermStructure(),
       Quote s0=SimpleQuote(),
       Real v0=0,
       Real kappa=0,
       Real theta=0,
       Real sigma=0,
       Real rho=0,
       Discretization d=PartialTruncation):

        #create handles
        self._thisptr = shared_ptr[_sp.StochasticProcess](
            new QlHestonProcess(
                risk_free_rate_ts._thisptr,
                dividend_ts._thisptr,
                s0.handle(),
                v0, kappa, theta, sigma, rho, d
            )
        )

    def __str__(self):
        return 'Heston process\nv0: %f kappa: %f theta: %f sigma: %f rho: %f' % \
          (self.v0, self.kappa, self.theta, self.sigma, self.rho)



    property v0:
        def __get__(self):
            return (<QlHestonProcess*>self._thisptr.get()).v0()

    property rho:
        def __get__(self):
            return (<QlHestonProcess*>self._thisptr.get()).rho()

    property kappa:
        def __get__(self):
            return (<QlHestonProcess*>self._thisptr.get()).kappa()

    property theta:
        def __get__(self):
            return (<QlHestonProcess*>self._thisptr.get()).theta()

    property sigma:
        def __get__(self):
            return (<QlHestonProcess*>self._thisptr.get()).sigma()

    @property
    def s0(self):
        cdef Handle[_qt.Quote] handle = (<QlHestonProcess*>self._thisptr.get()).s0()
        cdef Quote q = Quote.__new__(Quote)
        q._thisptr = handle.currentLink()
        return q
