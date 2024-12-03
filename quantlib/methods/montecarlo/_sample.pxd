from quantlib.types cimport Real
cdef extern from 'ql/methods/montecarlo/sample.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Sample[T]:
        T value
        Real weight
        Sample(const T& value, Real weight)
