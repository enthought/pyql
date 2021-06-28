cdef extern from 'ql/math/interpolations/backwardflatinterpolation.hpp' namespace 'QuantLib' nogil:

    cdef cppclass BackwardFlat:
        pass


cdef extern from 'ql/math/interpolations/loginterpolation.hpp' namespace 'QuantLib' nogil:

    cdef cppclass LogLinear:
        pass


cdef extern from 'ql/math/interpolations/linearinterpolation.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Linear:
        pass


cdef extern from 'ql/math/interpolations/bilinearinterpolation.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Bilinear:
        pass


cdef extern from 'ql/math/interpolations/bicubicsplineinterpolation.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Bicubic:
        pass

cdef extern from 'ql/math/interpolations/sabrinterpolation.hpp' namespace 'QuantLib' nogil:

    cdef cppclass SABRInterpolation:
        pass
