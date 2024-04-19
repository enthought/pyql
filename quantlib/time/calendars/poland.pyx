from . cimport _poland
from ..calendar cimport Calendar

cdef class Poland(Calendar):
    """Poland calendars"""

    def __cinit__(self):

        self._thisptr = _poland.Poland()
