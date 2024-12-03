from quantlib.types cimport Real, Size
from quantlib.methods.montecarlo._sample cimport Sample
from libcpp.vector cimport vector

cdef extern from 'ql/math/randomnumbers/inversecumulativersg.hpp' namespace 'QuantLib' nogil:
    #   Inverse cumulative random sequence generator
    #   It uses a sequence of uniform deviate in (0, 1) as the
    #     source of cumulative distribution values.
    #     Then an inverse cumulative distribution is used to calculate
    #     the distribution deviate.
    #     The uniform deviate sequence is supplied by USG.
    #     Class USG must implement the following interface:
    #     \code
    #         USG::sample_type USG::nextSequence() const;
    #         Size USG::dimension() const;
    #     \endcode
    #     The inverse cumulative distribution is supplied by IC.
    #     Class IC must implement the following interface:
    #     \code
    #         IC::IC();
    #         Real IC::operator() const;
    #     \endcode
    cdef cppclass InverseCumulativeRsg[USG, IC]:
        ctypedef Sample[vector[Real]] sample_type
        InverseCumulativeRsg[USG, IC]& InverseCumulativeRsg(const InverseCumulativeRsg[USG, IC]&)
        InverseCumulativeRsg(const USG& uniformSequenceGenerator)
        InverseCumulativeRsg(const USG& uniformSequenceGenerator,
                             const IC& inverseCumulative)
        # returns next sample from the inverse cumulative distribution
        const sample_type& nextSequence()
        const sample_type& lastSequence()
        Size dimension()
