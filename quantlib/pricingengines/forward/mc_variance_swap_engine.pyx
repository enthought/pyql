from quantlib.types cimport BigNatural, Integer, Real, Size
from cython.operator cimport dereference as deref

from libcpp cimport bool

from quantlib.utilities.null cimport Null
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.pricingengines._pricing_engine cimport PricingEngine as _PricingEngine
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess as _GeneralizedBlackScholesProcess
from ._mc_variance_swap_engine cimport MCVarianceSwapEngine as _MCVarianceSwapEngine



cdef class MCVarianceSwapEngine(PricingEngine):
    """Variance-swap pricing engine using Monte Carlo simulation

    as described in Demeterfi, Derman, Kamal & Zou,
    "A Guide to Volatility and Variance Swaps", 1999
    TODO define tolerance of numerical integral and incorporate it 
    in errorEstimate
    
    Test returned fair variances checked for consistency with
    implied volatility curve.

    Calculate variance via Monte Carlo

    Parameters
    ----------
    process : GeneralizedBlackScholesProcess
    time_steps : Size
    time_steps_per_year : Size
    brownian_bridge : bool
    antithetic_variate : bool
    required_samples : Size
    required_tolerance : Real
    max_samples : Size
    seed : BigNatural

    """
    def __init__(self,
                 GeneralizedBlackScholesProcess process,
                 Size time_steps = Null[Integer](),
                 Size time_steps_per_year = Null[Integer](),
                 bool brownian_bridge = False,
                 bool antithetic_variate = False,
                 Size required_samples = Null[Integer](),
                 Real required_tolerance = Null[Real](),
                 Size max_samples = Null[Integer](),
                 BigNatural seed = 0):
        # Cast the shared_ptr
        cdef shared_ptr[_GeneralizedBlackScholesProcess] process_ptr = \
             static_pointer_cast[_GeneralizedBlackScholesProcess](process._thisptr)
        self._thisptr.reset(
                        new _MCVarianceSwapEngine(process_ptr,
                                                  time_steps,
                                                  time_steps_per_year,
                                                  brownian_bridge,
                                                  antithetic_variate,
                                                  required_samples,
                                                  required_tolerance,
                                                  max_samples,
                                                  seed,
                                                  ))
