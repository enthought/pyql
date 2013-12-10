from quantlib.settings import utf8_char_array_to_py_compat_str

cdef class Index:

    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate Index')

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    property name:
       def __get__(self):
           return utf8_char_array_to_py_compat_str(self._thisptr.get().name().c_str())

