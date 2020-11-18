cimport quantlib.methods.finitedifferences.solvers._fdmbackwardsolver as _fdm

cdef class FdmSchemeDesc:
    cdef _fdm.FdmSchemeDesc* _thisptr
