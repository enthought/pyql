include '../types.pxi'

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
        Matrix operator=(const Matrix&)

cdef extern from 'ql/math/matrixutilities/pseudosqrt.hpp' namespace 'QuantLib':
    cdef cppclass SalvagingAlgorithm:
        enum Type:
            pass
    const Matrix pseudoSqrt(const Matrix&, SalvagingAlgorithm.Type)
