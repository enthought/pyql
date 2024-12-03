from cpython.ref cimport Py_INCREF
from quantlib.time_grid cimport TimeGrid
from quantlib.math.array cimport Array
from quantlib.types cimport Size
cimport numpy as np

np.import_array()

cdef class Path:
    def __init__(self, TimeGrid time_grid, Array values=Array()):
        self._thisptr = new _path.Path(time_grid._thisptr, values._thisptr)

    def __dealloc__(self):
        del self._thisptr

    def __len__(self):
        return self.this.length()

    def __getitem__(self, Size i):
        return self.this[i]

    def to_ndarray(self):
        cdef np.npy_intp[1] dims
        dims[0] = self.this.length()
        cdef arr = np.PyArray_SimpleNewFromData(1, &dims[0], np.NPY_DOUBLE, <void*>(&self._thisptr[0]))
        Py_INCREF(self)
        np.PyArray_SetBaseObject(arr, self)
        return arr
