include '../types.pxi'
from cython.operator import dereference as deref, preincrement as preinc
from libcpp.utility cimport move

cimport cython
cimport numpy as np
np.import_array()

cdef class Matrix:

    def __init__(self, Size rows, Size columns, value=None):
        if value is None:
            self._thisptr = move[QlMatrix](QlMatrix(rows, columns))
        else:
            self._thisptr = move[QlMatrix](QlMatrix(rows, columns, <Real?>value))

    @classmethod
    @cython.boundscheck(False)
    def from_ndarray(cls, double[:,::1] data):
        cdef Matrix instance = Matrix.__new__(Matrix)
        cdef Size rows = data.shape[0]
        cdef Size columns = data.shape[1]
        instance._thisptr = QlMatrix(rows, columns, &data[0,0], &data[-1,-1] + 1)
        return instance

    @cython.boundscheck(False)
    def to_ndarray(self):
        cdef np.npy_intp[2] dims
        dims[0] = self._thisptr.rows()
        dims[1] = self._thisptr.columns()
        cdef arr = np.PyArray_SimpleNew(2, &dims[0], np.NPY_DOUBLE)
        cdef double[:,::1] r = arr
        cdef size_t i, j
        for i in range(dims[0]):
            for j in range(dims[1]):
                r[i,j] = self._thisptr[i][j]
        return arr

    @property
    def rows(self):
        return self._thisptr.rows()

    @property
    def columns(self):
        return self._thisptr.columns()

    def __getitem__(self, coord):
        cdef size_t i, j
        i = coord[0]
        j = coord[1]
        return self._thisptr[i][j]

    def __setitem__(self, coord, Real val):
        cdef size_t i, j
        i, j = coord
        self._thisptr[i][j] = val
