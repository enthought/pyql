include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

from .._instrument cimport Instrument
from ._payoffs cimport Payoff, StrikedTypePayoff
from ._exercise cimport Exercise
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.pricingengines._pricing_engine cimport PricingEngine

cdef extern from 'ql/option.hpp' namespace 'QuantLib::Option':

    enum Type:
        Put
        Call

cdef extern from 'ql/option.hpp' namespace 'QuantLib':

    cdef cppclass Option(Instrument):

        shared_ptr[Payoff] payoff()
        shared_ptr[Exercise] exercise()

cdef extern from 'ql/instruments/oneassetoption.hpp' namespace 'QuantLib':

    cdef cppclass OneAssetOption(Option):
        OneAssetOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )
        bool isExpired()
        Real delta() except +
        Real deltaForward() except +
        Real elasticity() except +
        Real gamma() except +
        Real theta() except +
        Real thetaPerDay() except +
        Real vega() except +
        Real rho() except +
        Real dividendRho() except +
        Real strikeSensitivity() except +
        Real itmCashProbability() except +


cdef extern from 'ql/instruments/vanillaoption.hpp' namespace 'QuantLib':

    cdef cppclass VanillaOption(OneAssetOption):
        VanillaOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )
        Volatility impliedVolatility(
                Real price,
                shared_ptr[GeneralizedBlackScholesProcess]& process,
                Real accuracy,
                Size maxEvaluations,
                Volatility minVol,
                Volatility maxVol
        ) except +


cdef extern from 'ql/instruments/europeanoption.hpp' namespace 'QuantLib':

    cdef cppclass EuropeanOption(VanillaOption):
        EuropeanOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )

cdef extern from 'ql/instruments/dividendvanillaoption.hpp' namespace 'QuantLib':

    cdef cppclass DividendVanillaOption(OneAssetOption):
        cppclass engine(PricingEngine):
            pass
