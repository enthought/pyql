cimport cython
from quantlib.types cimport Real

from quantlib.handle cimport shared_ptr
cimport quantlib.methods.finitedifferences.solvers._fdmbackwardsolver as _fdm

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

    @staticmethod
    def Douglas():
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.Douglas())
        return r

    @staticmethod
    def CrankNicolson():
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.CrankNicolson())
        return r

    @staticmethod
    def ImplicitEuler():
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.ImplicitEuler())
        return r

    @staticmethod
    def ExplicitEuler():
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.ExplicitEuler())
        return r

    @staticmethod
    def CraigSneyd():
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.CraigSneyd())
        return r

    @staticmethod
    def ModifiedCraigSneyd():
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.Hundsdorfer())
        return r

    @staticmethod
    def Hundsdorfer():
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.ModifiedHundsdorfer())
        return r

    @staticmethod
    def MethodOfLines(Real eps=0.001, Real relInitStepSize=0.01):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.MethodOfLines(eps, relInitStepSize))
        return r

    @classmethod
    def TrBDF2(cls):
        cdef FdmSchemeDesc r = FdmSchemeDesc.__new__(FdmSchemeDesc)
        r._thisptr = new _fdm.FdmSchemeDesc(_fdm.FdmSchemeDesc.TrBDF2())
        return r
