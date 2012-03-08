cimport _optimization as _opt

from quantlib.handle cimport shared_ptr

cdef class OptimizationMethod:

    cdef shared_ptr[_opt.OptimizationMethod]* _thisptr

cdef class EndCriteria:

    cdef shared_ptr[_opt.EndCriteria]* _thisptr


