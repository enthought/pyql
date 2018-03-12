from quantlib.handle cimport shared_ptr
cimport quantlib.termstructures.credit._credit_helpers as _ci

cdef class DefaultProbabilityHelper:
    cdef shared_ptr[_ci.DefaultProbabilityHelper] _thisptr

cdef class CdsHelper(DefaultProbabilityHelper):
    pass

cdef class SpreadCdsHelper(CdsHelper):
    pass

cdef class UpfrontCdsHelper(CdsHelper):
    pass
