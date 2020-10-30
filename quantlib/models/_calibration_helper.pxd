include '../types.pxi'

from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.handle cimport shared_ptr

cdef extern from 'ql/models/calibrationhelper.hpp' namespace 'QuantLib':

    cdef cppclass BlackCalibrationHelper:
        BlackCalibrationHelper()

        Volatility impliedVolatility(
            Real targetValue,
            Real accuracy,
            Size maxEvaluation,
            Volatility minVol,
            Volatility maxVol) except +

        void setPricingEngine(shared_ptr[PricingEngine]& engine) except +

        Real blackPrice(Real volatility) except +

        Real marketValue() except +
        Real modelValue() except +
        Real calibrationError() except +


cdef extern from 'ql/models/calibrationhelper.hpp' namespace 'QuantLib::BlackCalibrationHelper':

    cdef enum CalibrationErrorType:
        RelativePriceError
        PriceError
        ImpliedVolError
