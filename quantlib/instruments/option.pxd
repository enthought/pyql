from quantlib.handle cimport shared_ptr
cimport _exercise
cimport _option

cdef class Exercise:
    cdef shared_ptr[_exercise.Exercise] _thisptr
