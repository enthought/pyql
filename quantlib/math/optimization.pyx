from quantlib.handle cimport shared_ptr
from cython.operator cimport dereference as deref

cimport _optimization as _opt
from quantlib.math.array cimport Array

cdef class OptimizationMethod:
    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if  self._thisptr is not NULL:
            del self._thisptr

cdef class LevenbergMarquardt(OptimizationMethod):

    def __init__(self, double epsfcn=1e-8, double xtol=1e-8, double gtol=1e-8):
        self._thisptr = new shared_ptr[_opt.OptimizationMethod](
            new _opt.LevenbergMarquardt(
                epsfcn,
                xtol,
                gtol
            )
        )

cdef class EndCriteria:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass

    def __init__(self, int max_iterations, int max_stationary_state_iterations,
            double root_epsilon, double function_epsilon,
            double gradient_epsilon
    ):
        self._thisptr = new shared_ptr[_opt.EndCriteria](
            new _opt.EndCriteria(
                max_iterations,
                max_stationary_state_iterations,
                root_epsilon,
                function_epsilon,
                gradient_epsilon
            )
        )


cdef class Constraint:
    def __cinit__(self):
        self._thisptr = NULL

    def __init__(self):
        raise ValueError('Cannot instantiate a Constraint')

    def __dealloc__(self):
        if  self._thisptr is not NULL:
            del self._thisptr

    def test(self, Array a):
        return self._thisptr.get().test(deref(a._thisptr.get()))
