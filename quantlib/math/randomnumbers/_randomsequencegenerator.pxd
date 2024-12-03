from libcpp.vector cimport vector
from quantlib.types cimport Real, Size
from quantlib._stochastic_process cimport StochasticProcess
from quantlib.methods.montecarlo._sample cimport Sample

cdef extern from 'ql/math/randomnumbers/randomsequencegenerator.hpp' namespace 'QuantLib' nogil:
    cdef cppclass RandomSequenceGenerator[RNG]:
        ctypedef Sample[vector[Real]] sample_type
        RandomSequenceGenerator(Size dimensionality,
                                const RNG& rgn)
        const sample_type& nextSequence() const
        const sample_type& lastSequence() const
        Size dimension() const
