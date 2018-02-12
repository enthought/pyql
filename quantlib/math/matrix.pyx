include '../types.pxi'
from cython.operator import dereference as deref, preincrement as preinc
cimport cython

cimport numpy as np
import numpy as np

cdef class Matrix:

    def __init__(self, Size rows, Size columns, value=None):
        if value is None:
            self._thisptr = QlMatrix(rows, columns)
        else:
            self._thisptr = QlMatrix(rows, columns, <Real?>value)

    @classmethod
    @cython.boundscheck(False)
    def from_ndarray(cls, double[:,::1] data):
        cdef Matrix instance = cls.__new__(cls)
        cdef Size rows = data.shape[0]
        cdef Size columns = data.shape[1]
        instance._thisptr = QlMatrix(rows, columns, &data[0,0], &data[-1, -1] + 1)
        return instance

    @cython.boundscheck(False)
    def to_ndarray(self):
        cdef double[:,::1] r = np.empty((self._thisptr.rows(),
            self._thisptr.columns()))
        cdef size_t i, j
        for i in range(self._thisptr.rows()):
            for j in range(self._thisptr.columns()):
                r[i,j] = self._thisptr[i][j]
        return np.array(r)

    @property
    def rows(self):
        return self._thisptr.rows()

    @property
    def columns(self):
        return self._thisptr.columns()
