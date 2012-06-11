
cdef extern from 'ql/math/interpolations/backwardflatinterpolation.h' namespace 'QuantLib':

    class BackwardFlat:
        pass


cdef extern from 'ql/math/interpolations/loginterpolation.hpp' namespace 'QuantLib':

    class LogLinear:
        pass

cdef extern from 'ql/math/interpolations/linearinterpolation.hpp' namespace 'QuantLib':

    class Linear:
        pass
