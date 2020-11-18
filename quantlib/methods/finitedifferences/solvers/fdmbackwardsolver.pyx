cimport cython
from quantlib.types cimport Real

from quantlib.handle cimport shared_ptr
cimport quantlib.methods.finitedifferences.solvers._fdmbackwardsolver as _fdm

cpdef enum FdmSchemeType:
    HundsdorferType = _fdm.HundsdorferType
    DouglasType = _fdm.DouglasType
    CraigSneydType = _fdm.CraigSneydType
    ModifiedCraigSneydType = _fdm.ModifiedCraigSneydType
    ImplicitEulerType = _fdm.ImplicitEulerType
    ExplicitEulerType = _fdm.ExplicitEulerType

cdef class FdmLinearOpComposite:
    pass

cdef class FdmStepConditionComposite:
    pass

@cython.final
cdef class FdmSchemeDesc:

    def __dealloc__(self):
        del self._thisptr

    def __init__(self, FdmSchemeType type, Real theta, Real mu):
        self._thisptr = new _fdm.FdmSchemeDesc(type, theta, mu)

    @property
    def type(self):
        return FdmSchemeType(self._thisptr.type)

    @property
    def theta(self):
        return self._thisptr.theta

    @property
    def mu(self):
        return self._thisptr.mu

    @classmethod
    def Douglas(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.Douglas())
        return r
    @classmethod
    def CrankNicolson(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.CrankNicolson())
        return r

    @classmethod
    def ImplicitEuler(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.ImplicitEuler())
        return r

    @classmethod
    def ExplicitEuler(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.ExplicitEuler())
        return r

    @classmethod
    def CraigSneyd(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.CraigSneyd())
        return r

    @classmethod
    def ModifiedCraigSneyd(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.Hundsdorfer())
        return r

    @classmethod
    def Hundsdorfer(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.ModifiedHundsdorfer())
        return r

    @classmethod
    def MethodOfLines(cls, Real eps=0.001, Real relInitStepSize=0.01):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.MethodOfLines(eps, relInitStepSize))
        return r

    @classmethod
    def TrBDF2(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.TrBDF2())
        return r
