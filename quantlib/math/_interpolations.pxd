cdef extern from 'ql/math/interpolations/backwardflatinterpolation.hpp' namespace 'QuantLib':

    cdef cppclass BackwardFlat:
        pass

cdef extern from 'ql/math/interpolations/loginterpolation.hpp' namespace 'QuantLib':

    cdef cppclass LogLinear:
        pass

cdef extern from 'ql/math/interpolations/linearinterpolation.hpp' namespace 'QuantLib':

    cdef cppclass Linear:
        pass
