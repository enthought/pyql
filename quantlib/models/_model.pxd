include '../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.math._array cimport Array

cdef extern from 'ql/models/model.hpp' namespace 'QuantLib':

    cdef cppclass CalibratedModel:
        CalibratedModel()
        
        Array& params()
        void setParams(Array& params) 
