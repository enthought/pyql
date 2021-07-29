from .._matrix cimport Matrix

cdef extern from 'ql/math/matrixutilities/pseudosqrt.hpp' namespace 'QuantLib::SalvagingAlgorithm':
    cpdef enum SalvagingAlgorithm "QuantLib::SalvagingAlgorithm::Type":
        Nothing "QuantLib::SalvagingAlgorithm::None"
        Spectral
        Hypersphere
        LowerDiagonal
        Higham

cdef extern from 'ql/math/matrixutilities/pseudosqrt.hpp' namespace 'QuantLib':
    const Matrix pseudoSqrt(const Matrix&, SalvagingAlgorithm)
