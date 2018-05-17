cdef extern from 'ql/math/interpolations/all.hpp' namespace 'QuantLib':
    cdef cppclass Linear:
        pass

    cdef cppclass LogLinear:
        pass

    cdef cppclass BackwardFlat:
        pass

    cdef cppclass SABRInterpolation:
        pass
