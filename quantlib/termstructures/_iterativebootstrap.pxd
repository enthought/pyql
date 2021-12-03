from quantlib.types cimport Real, Size
from libcpp cimport bool

cdef extern from 'ql/termstructures/iterativebootstrap.hpp' namespace 'QuantLib':
    cdef cppclass IterativeBootstrap[C]:
        IterativeBootstrap(Real accuracy)
        IterativeBootstrap(Real accuracy, # = Null<Real>(),
                           Real minValue,  # = Null<Real>(),
                           Real maxValue, # = Null<Real>(),
                           Size maxAttempts, # = 1,
                           Real maxFactor, # = 2.0,
                           Real minFactor, # = 2.0,
                           bool dontThrow, # = false,
                           Size dontThrowSteps)
