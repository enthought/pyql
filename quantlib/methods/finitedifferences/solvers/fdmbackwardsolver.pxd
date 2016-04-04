cimport quantlib.methods.finitedifferences.solvers._fdmbackwardsolver as _fdm
from quantlib.handle cimport shared_ptr


cdef class FdmSchemeDesc:
    cdef shared_ptr[_fdm.FdmSchemeDesc]* _thisptr
