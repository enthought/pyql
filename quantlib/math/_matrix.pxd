include '../types.pxi'

cdef extern from 'ql/utilities/disposable.hpp' namespace 'QuantLib':
    cdef cppclass Disposable[T]:
        Disposable(T&)

cdef extern from 'ql/math/matrix.hpp' namespace 'QuantLib':
    cdef cppclass Matrix:
        Matrix()
        Matrix(Size rows, Size columns)
        Matrix(Size rows, Size columns, Real value)
        Matrix(Size rows, Size columns, Real* begin, Real* end)
        Size rows()
        Size columns()
        Real* begin()
        Real* operator[](Size)
        Matrix operator=(const Disposable[Matrix]&)

cdef extern from 'ql/math/matrixutilities/pseudosqrt.hpp' namespace 'QuantLib::SalvagingAlgorithm':
    enum Type:
        Nothing "QuantLib::SalvagingAlgorithm::None"
        Spectral
        Hypersphere
        LowerDiagonal
        Higham

cdef extern from 'ql/math/matrixutilities/pseudosqrt.hpp' namespace 'QuantLib':
    const Disposable[Matrix] pseudoSqrt(const Matrix&,
                                        Type)
