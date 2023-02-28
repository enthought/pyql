cimport quantlib.methods.finitedifferences.solvers._fdmbackwardsolver as _fdm

cdef extern from 'ql/methods/finitedifferences/solvers/fdmbackwardsolver.hpp' namespace 'QuantLib::FdmSchemeDesc':
    cpdef enum FdmSchemeType:
        HundsdorferType
        DouglasType
        CraigSneydType
        ModifiedCraigSneydType
        ImplicitEulerType
        ExplicitEulerType
        MethodOfLinesType
        TrBDF2Type
        CrankNicolsonType

cdef class FdmSchemeDesc:
    cdef _fdm.FdmSchemeDesc* _thisptr
