from libcpp cimport bool
from quantlib._time_grid cimport TimeGrid
from libcpp.vector cimport vector
from ._multipath cimport Path
from ._sample cimport Sample
from quantlib._stochastic_process cimport StochasticProcess

cdef extern from 'ql/methods/montecarlo/pathgenerator.hpp' namespace 'QuantLib' nogil:
    cdef cppclass PathGenerator[GSG]:
        ctypedef Sample[Path] sample_type
        MultiPathGenerator(const shared_ptr[StochasticProcess]&,
                           const TimeGrid&,
                           GSG generator,
                           bool brownianBridge) # = false)
        const sample_type& next()
        const sample_type& antithetic()
        Size size()
