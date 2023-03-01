from libcpp.vector cimport vector
from quantlib.types cimport Real, Size
from quantlib.handle cimport shared_ptr

cdef extern from 'ql/models/marketmodels/browniangenerator.hpp' namespace 'QuantLib' nogil:
    cdef cppclass BrownianGenerator:
        Real nextStep(vector[Real]&) except +
        Real nextPath()

        Size numberOfFactors() const
        Size numberOfSteps() const

    cdef cppclass BrownianGeneratorFactory:
        shared_ptr[BrownianGenerator] create(Size factor, Size steps) const
