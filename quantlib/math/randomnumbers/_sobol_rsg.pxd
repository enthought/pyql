include '../../types.pxi'
from libcpp.vector cimport vector
from libc.stdint cimport uint_least32_t
from quantlib.methods.montecarlo._sample cimport Sample

cdef extern from 'ql/math/randomnumbers/sobolrsg.hpp' namespace 'QuantLib' nogil:
    cdef cppclass SobolRsg:
        ctypedef Sample[vector[Real]] sample_type
        enum DirectionIntegers:
            Unit
            Jaeckel
            SobolLevitan
            SobolLevitanLemieux
            JoeKuoD5
            JoeKuoD6
            JoeKuoD7
            Kuo
            Kuo2
            Kuo3
        # dimensionality must be <= PPMT_MAX_DIM
        SobolRsg(Size dimensionality,
                 unsigned long seed, # = 0,
                 DirectionIntegers directionIntegers) # = Jaeckel);
        # skip to the n-th sample in the low-discrepancy sequence
        void skipTo(uint_least32_t n)
        const vector[uint_least32_t]& nextInt32Sequence() const
        const SobolRsg.sample_type& nextSequence()
        const sample_type& lastSequence()
        Size dimension()
