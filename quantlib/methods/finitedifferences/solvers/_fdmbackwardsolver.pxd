include '../../../types.pxi'

from libcpp cimport bool

cdef extern from 'ql/methods/finitedifferences/solvers/fdmbackwardsolver.hpp' namespace 'QuantLib::FdmSchemeDesc':
        cdef enum FdmSchemeType:
            HundsdorferType
            DouglasType
            CraigSneydType
            ModifiedCraigSneydType 
            ImplicitEulerType
            ExplicitEulerType

cdef extern from 'ql/methods/finitedifferences/solvers/fdmbackwardsolver.hpp' namespace 'QuantLib':

    cdef cppclass FdmLinearOpComposite:
        pass
    
    cdef cppclass FdmStepConditionComposite:
        pass

    cdef cppclass FdmSchemeDesc:
        
        FdmSchemeDesc()
    
        FdmSchemeDesc(FdmSchemeType type, Real theta, Real mu)

    FdmSchemeDesc Douglas "FdmSchemeDesc::Douglas"()

    FdmSchemeDesc ImplicitEuler"FdmSchemeDesc::ImplicitEuler"()
        
    FdmSchemeDesc ExplicitEuler "FdmSchemeDesc::Douglas"()
        
    FdmSchemeDesc CraigSneyd "FdmSchemeDesc::Douglas"()
        
    FdmSchemeDesc ModifiedCraigSneyd "FdmSchemeDesc::Douglas"()
        
    FdmSchemeDesc Hundsdorfer "FdmSchemeDesc::Douglas"()
        
    FdmSchemeDesc ModifiedHundsdorfer "FdmSchemeDesc::Douglas"()
