from quantlib.types cimport Real
from .._option cimport Option
from quantlib.handle cimport shared_ptr
from .._exercise cimport Exercise
from .._payoffs cimport StrikedTypePayoff
from quantlib.pricingengines._pricing_engine cimport PricingEngine

cdef extern from 'ql/instruments/oneassetoption.hpp' namespace 'QuantLib' nogil:

    cdef cppclass OneAssetOption(Option):
        cppclass engine(PricingEngine):
            pass
        OneAssetOption(
            shared_ptr[StrikedTypePayoff]& payoff,
            shared_ptr[Exercise]& exercise
        )
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
