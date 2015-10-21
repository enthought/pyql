include '../../../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.methods.finitedifferences.solvers cimport _fdmbackwardsolver as _fdm
import numpy as np

cdef public enum FdmSchemeType:
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

cdef class FdmSchemeDesc:
    
    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __cinit__(self):
        pass

    def __init__(self, FdmSchemeType type, Real theta, Real mu):
        self._thisptr = new shared_ptr[_fdm.FdmSchemeDesc](
            new _fdm.FdmSchemeDesc(type, theta, mu))

    @classmethod
    def Douglas(cls):
        return FdmSchemeDesc(DouglasType, 0.5, 0.0)
    
    @classmethod
    def CraigSneyd(cls):
        return FdmSchemeDesc(CraigSneydType,0.5, 0.5)

    @classmethod
    def ModifiedCraigSneyd(cls): 
        return FdmSchemeDesc(ModifiedCraigSneydType, 1.0/3.0, 1.0/3.0)

    @classmethod
    def Hundsdorfer(cls):
        return FdmSchemeDesc(HundsdorferType, 0.5+np.sqrt(3.0)/6, 0.5)

    @classmethod
    def ModifiedHundsdorfer(cls):
        return FdmSchemeDesc(HundsdorferType, 1.0-np.sqrt(2.0)/2, 0.5)
    
    @classmethod
    def ExplicitEuler(cls):
        return FdmSchemeDesc(ExplicitEulerType, 0.0, 0.0)

    @classmethod
    def ImplicitEuler(cls):
        return FdmSchemeDesc(ImplicitEulerType, 0.0, 0.0)

