from quantlib.types cimport Real

from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr
from quantlib.math._optimization cimport Constraint, EndCriteria, OptimizationMethod
from quantlib.math._array cimport Array
from ._calibration_helper cimport CalibrationHelper

cdef extern from 'ql/models/model.hpp' namespace 'QuantLib':

    cdef cppclass CalibratedModel:
        void calibrate(
                const vector[shared_ptr[CalibrationHelper]]&,
                OptimizationMethod& method,
                const EndCriteria& endCriteria,
                const Constraint& constraint,# = Constraint(),
                const vector[Real]& weights, # = std::vector<Real>(),
                const vector[bool]& fixParameters # = std::vector<bool>());
            )
        Array& params()
        void setParams(Array& params)
