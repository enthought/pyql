from quantlib.types cimport Real

cdef extern from 'ql/methods/finitedifferences/solvers/fdmbackwardsolver.hpp' namespace 'QuantLib::FdmSchemeDesc':
    cdef enum FdmSchemeType:
        HundsdorferType
        DouglasType
        CraigSneydType
        ModifiedCraigSneydType
        ImplicitEulerType
        ExplicitEulerType
        MethodOfLinesType
        TrBDF2Type
        CrankNicolsonType

cdef extern from 'ql/methods/finitedifferences/solvers/fdmbackwardsolver.hpp' namespace 'QuantLib':
   cdef cppclass FdmSchemeDesc:
       enum FdmSchemeType:
           pass

       FdmSchemeDesc(FdmSchemeDesc&) # default copy constructor
       FdmSchemeDesc(FdmSchemeType type, Real theta, Real mu);

       const FdmSchemeType type
       const Real theta
       const Real mu

       #some default schema descriptions
       @staticmethod
       FdmSchemeDesc Douglas() # same as Crank-Nicolson in 1 dimension
       @staticmethod
       FdmSchemeDesc CrankNicolson()
       @staticmethod
       FdmSchemeDesc ImplicitEuler()
       @staticmethod
       FdmSchemeDesc ExplicitEuler()
       @staticmethod
       FdmSchemeDesc CraigSneyd()
       @staticmethod
       FdmSchemeDesc ModifiedCraigSneyd()
       @staticmethod
       FdmSchemeDesc Hundsdorfer()
       @staticmethod
       FdmSchemeDesc ModifiedHundsdorfer()
       @staticmethod
       FdmSchemeDesc MethodOfLines(
            Real eps, Real relInitStepSize)
       @staticmethod
       FdmSchemeDesc TrBDF2()
