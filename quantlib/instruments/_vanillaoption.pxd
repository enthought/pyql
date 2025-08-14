from quantlib.types cimport Real, Size, Volatility
from ._oneassetoption cimport OneAssetOption
from ._dividendschedule cimport DividendSchedule
from .._payoffs cimport StrikedTypePayoff
from .._exercise cimport Exercise

from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.handle cimport shared_ptr

cdef extern from 'ql/instruments/vanillaoption.hpp' namespace 'QuantLib' nogil:

    cdef cppclass VanillaOption(OneAssetOption):
        VanillaOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )
        Volatility impliedVolatility(
                Real price,
                shared_ptr[GeneralizedBlackScholesProcess]& process,
                Real accuracy, # 1.0e-4
                Size maxEvaluations, #100
                Volatility minVol, # 1.0e-7
                Volatility maxVol # 4.0
        ) except +
        Volatility impliedVolatility(
                Real price,
                shared_ptr[GeneralizedBlackScholesProcess]& process,
                DividendSchedule dividends,
                Real accuracy, # 1.0e-4
                Size maxEvaluations, #100
                Volatility minVol, # 1.0e-7
                Volatility maxVol # 4.0
        ) except +
