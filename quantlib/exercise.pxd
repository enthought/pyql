from quantlib.handle cimport shared_ptr
from . cimport _exercise

cdef extern from 'ql/exercise.hpp' namespace 'QuantLib::Exercise' nogil:
    cpdef enum class Type:
        """Exercise types

        Attributes
        ----------
        American
        Bermudan
        European
        """
        American
        Bermudan
        European

cdef class Exercise:
    cdef shared_ptr[_exercise.Exercise] _thisptr
