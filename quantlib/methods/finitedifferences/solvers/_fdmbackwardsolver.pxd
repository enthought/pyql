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

        ## @staticmethod
        ## FdmSchemeDesc Douglas()
        
        ## @staticmethod
        ## FdmSchemeDesc ImplicitEuler()
        
        ## @staticmethod
        ## FdmSchemeDesc ExplicitEuler()
        
        ## @staticmethod
        ## FdmSchemeDesc CraigSneyd()
        
        ## @staticmethod
        ## FdmSchemeDesc ModifiedCraigSneyd()
        
        ## @staticmethod
        ## FdmSchemeDesc Hundsdorfer()
        
        ## @staticmethod
        ## FdmSchemeDesc ModifiedHundsdorfer()
