cdef extern from 'ql/termstructures/yield/bootstraptraits.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Discount:
        pass

    cdef cppclass ZeroYield:
        pass

    cdef cppclass ForwardRate:
        pass
