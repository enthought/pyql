from quantlib.handle cimport shared_ptr
cimport quantlib.instruments._exercise as _exercise

cdef extern from 'ql/exercise.hpp' namespace 'QuantLib::Exercise' nogil:
    cpdef enum class Type:
        American
        Bermudan
        European

cdef class Exercise:
    cdef shared_ptr[_exercise.Exercise] _thisptr
