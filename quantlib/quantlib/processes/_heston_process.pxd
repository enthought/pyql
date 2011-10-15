include '../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure, Quote


cdef extern from 'ql/processes/hestonprocess.hpp' namespace 'QuantLib':

    cdef cppclass HestonProcess:
        # fixme: implement the discrization version of the constructor
        HestonProcess(
            Handle[YieldTermStructure]& riskFreeRate,
            Handle[YieldTermStructure]& dividendYield,
            Handle[Quote]& s0,
            Real v0, Real kappa,
            Real theta, Real sigma, Real rho)
            
        Size size()
        Real v0()
        Real rho()
        Real kappa()
        Real theta()
        Real sigma()

        Handle[Quote] s0()
        Handle[YieldTermStructure] dividendYield()
        Handle[YieldTermStructure] riskeFreeRate()


