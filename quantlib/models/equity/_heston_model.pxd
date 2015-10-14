include '../../types.pxi'

from libcpp.vector cimport vector

from quantlib.handle cimport Handle, shared_ptr
from quantlib.math._optimization cimport OptimizationMethod, EndCriteria
from quantlib.processes._heston_process cimport HestonProcess
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.termstructures.yields._flat_forward cimport (
    YieldTermStructure
)
from quantlib.models._calibration_helper cimport CalibrationHelper, CalibrationErrorType
from quantlib.math._optimization cimport Constraint

cimport quantlib.models._calibration_helper as _ch
cimport quantlib._quote as _qt
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Period

cdef extern from 'ql/models/equity/hestonmodelhelper.hpp' namespace 'QuantLib':

    cdef cppclass HestonModelHelper(CalibrationHelper):

        HestonModelHelper(
            Period& maturity,
            Calendar& calendar,
            Real s0, 
            Real strikePrice,
            Handle[_qt.Quote]& volatility,
            Handle[YieldTermStructure]& riskFreeRate,
            Handle[YieldTermStructure]& dividendYield,
            CalibrationErrorType errorType
        ) except +
        

cdef extern from 'ql/models/equity/hestonmodel.hpp' namespace 'QuantLib':

    cdef cppclass HestonModel:

        HestonModel() # fake empty constructor solving Cython dep. issue
        HestonModel(shared_ptr[HestonProcess]& process)

        shared_ptr[HestonProcess] process() except +
        
        #variance mean reversion level
        Real theta() except +
        #variance mean reversion speed
        Real kappa() except +
        # volatility of the volatility
        Real sigma() except +
        # correlation
        Real rho() except +
        # spot variance
        Real v0() except +

        void calibrate(
               vector[shared_ptr[_ch.CalibrationHelper]]&,
               OptimizationMethod& method,
               EndCriteria& endCriteria) except +

        void calibrate(
               vector[shared_ptr[_ch.CalibrationHelper]]&,
               OptimizationMethod& method,
               EndCriteria& endCriteria,
               Constraint& constraint) except +


