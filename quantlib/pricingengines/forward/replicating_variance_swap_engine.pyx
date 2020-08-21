include '../../types.pxi'

from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess as _GeneralizedBlackScholesProcess
from quantlib.pricingengines._pricing_engine cimport PricingEngine as _PricingEngine
from quantlib.pricingengines.engine cimport PricingEngine
from _replicating_variance_swap_engine cimport ReplicatingVarianceSwapEngine as _ReplicatingVarianceSwapEngine

cdef class ReplicatingVarianceSwapEngine(PricingEngine):
    """
        Variance-swap pricing engine using replicating cost,
        as described in Demeterfi, Derman, Kamal & Zou,
        "A Guide to Volatility and Variance Swaps", 1999

        Attributes
        ---------
        process : :obj:`GeneralizedBlackScholesProcess`
        call_strikes : list of :obj:`Real`
        put_strikes : list of :obj:`Real`
        dk : Real
            5.0


    """

    def __init__(self,
                 GeneralizedBlackScholesProcess process,
                 vector[Real] call_strikes,
                 vector[Real] put_strikes,
                 Real dk = 5.0,
                 ):
        # build the ptr
        cdef shared_ptr[_GeneralizedBlackScholesProcess] process_ptr = \
             static_pointer_cast[_GeneralizedBlackScholesProcess](process._thisptr)

        self._thisptr = new shared_ptr[_PricingEngine](new \
                        _ReplicatingVarianceSwapEngine(process_ptr,
                                                       dk,
                                                       call_strikes,
                                                       put_strikes))
