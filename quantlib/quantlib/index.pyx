cdef class Index:

    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate Index')

    def __dealloc__(self):
        if self._thisptr:
            del self._thisptr

    property name:
       def __get__(self):
           return self._thisptr.name().c_str()

