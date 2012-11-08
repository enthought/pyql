cdef class PricingEngine:
    """ Base class for all the pricing engines. """

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr


