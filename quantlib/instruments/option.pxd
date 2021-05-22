from quantlib.handle cimport shared_ptr
cimport quantlib.instruments._exercise as _exercise
from quantlib.instruments.instrument cimport Instrument

cdef class Exercise:
    cdef shared_ptr[_exercise.Exercise] _thisptr


cdef class OneAssetOption(Instrument):
    pass
