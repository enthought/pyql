include '../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure
cimport quantlib._quote as _qt


cdef extern from 'ql/processes/hestonprocess.hpp' namespace 'QuantLib':

    cdef cppclass HestonProcess:
        HestonProcess() # fake empty constructor for Cython
        # fixme: implement the discrization version of the constructor
        HestonProcess(
            Handle[YieldTermStructure]& riskFreeRate,
            Handle[YieldTermStructure]& dividendYield,
            Handle[_qt.Quote]& s0,
            Real v0, Real kappa,
            Real theta, Real sigma, Real rho)
            
        Size size()
        Real v0()
        Real rho()
        Real kappa()
        Real theta()
        Real sigma()

        Handle[_qt.Quote] s0()
        Handle[YieldTermStructure] dividendYield()
        Handle[YieldTermStructure] riskeFreeRate()

cdef extern from 'ql/processes/batesprocess.hpp' namespace 'QuantLib':

    cdef cppclass BatesProcess(HestonProcess):
        BatesProcess(
            Handle[YieldTermStructure]& riskFreeRate,
            Handle[YieldTermStructure]& dividendYield,
            Handle[_qt.Quote]& s0,
            Real v0, Real kappa,
            Real theta, Real sigma, Real rho,
            Real lambda_, Real nu, Real delta)

        Real lambda_()
        Real nu()
        Real delta()

