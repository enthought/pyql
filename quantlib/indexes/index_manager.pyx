# cython: c_string_type=unicode, c_string_encoding=ascii
cimport quantlib.indexes._index_manager as _im

cdef class IndexManager:

    @staticmethod
    def histories():
        return _im.IndexManager.instance().histories()
