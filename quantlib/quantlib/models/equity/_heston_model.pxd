# distutils: language = c++
# distutils: libraries = QuantLib


include '../../types.pxi'

from libcpp.vector cimport vector

from quantlib.handle cimport Handle, shared_ptr
from quantlib.math._optimization cimport OptimizationMethod, EndCriteria
from quantlib.processes._heston_process cimport HestonProcess
from quantlib.pricingengines._vanilla cimport PricingEngine
from quantlib.termstructures.yields._flat_forward cimport (
    YieldTermStructure, Quote
)
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Period

cdef extern from 'ql/models/calibrationhelper.hpp' namespace 'QuantLib':

    cdef cppclass CalibrationHelper:
        pass

cdef extern from 'ql/models/equity/hestonmodelhelper.hpp' namespace 'QuantLib':

    cdef cppclass HestonModelHelper(CalibrationHelper):
        HestonModelHelper(
            Period& maturity,
            Calendar& calendar,
            Real s0,
            Real strikePrice,
            Handle[Quote]& volatility,
            Handle[YieldTermStructure]& riskFreeRate,
            Handle[YieldTermStructure]& dividendYield,
        )

        void setPricingEngine(shared_ptr[PricingEngine]& engine) 
        Real modelValue()
        Real blackPrice(Real volatility)

cdef extern from 'ql/models/equity/hestonmodel.hpp' namespace 'QuantLib':

    cdef cppclass HestonModel:
        HestonModel(shared_ptr[HestonProcess]& process)

        #variance mean version level
        Real theta()
        #variance mean reversion speed
        Real kappa()
        # volatility of the volatility
        Real sigma()
        # correlation
        Real rho() 
        # spot variance
        Real v0() 

        void calibrate(
               vector[shared_ptr[CalibrationHelper]]&,
               OptimizationMethod& method,
               EndCriteria& endCriteria,
        )



