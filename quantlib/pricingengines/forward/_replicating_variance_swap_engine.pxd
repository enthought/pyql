include '../../types.pxi'

from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr

from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess

cdef extern from 'ql/pricingengines/forward/replicatingvarianceswapengine.hpp' namespace 'QuantLib':

    cdef cppclass ReplicatingVarianceSwapEngine(PricingEngine):

        ReplicatingVarianceSwapEngine(
             shared_ptr[GeneralizedBlackScholesProcess]& process,
             Real dk, # = 5.0,
             vector[Real]& callStrikes, #= vector[Real](),
             vector[Real]& putStrikes, #= vector[Real]()
             ) except +
