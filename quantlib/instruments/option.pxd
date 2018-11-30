from quantlib.handle cimport shared_ptr
cimport quantlib.instruments._exercise as _exercise

cdef class Exercise:
    cdef shared_ptr[_exercise.Exercise] _thisptr
