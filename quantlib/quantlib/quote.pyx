cdef class Quote:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass

    property is_valid:
        def __get__(self):
            return self._thisptr.get().isValid()

    property value:
        def __get__(self):
            if self._thisptr.get().isValid():
                return self._thisptr.get().value()
            else:
                return None
