from cython.operator cimport dereference as deref
from quantlib.types cimport Size
from quantlib.time_grid cimport TimeGrid
from libcpp.utility cimport move
from .path cimport Path
from . cimport _path

cdef class MultiPath:
    def __init__(self, Size n_assets, TimeGrid time_grid):
        pass

    def __getitem__(self, Size j):
        cdef Path p = Path.__new__(Path)
        p._thisptr = new _path.Path(deref(self._thisptr)[j])
        return p
