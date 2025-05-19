from libcpp cimport bool
from quantlib.types cimport Real, Time, Volatility
from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._date cimport Date
from quantlib._quote cimport Quote
from ._local_vol_term_structure cimport LocalVolTermStructure
from ._black_vol_term_structure cimport BlackVolTermStructure

cdef extern from 'ql/termstructures/volatility/equityfx/localvolsurface.hpp' namespace 'QuantLib' nogil:

    cdef cppclass LocalVolSurface(LocalVolTermStructure):
        # Local volatility surface derived from a Black vol surface
        # For details about this implementation refer to
        # "Stochastic Volatility and Local Volatility," in
        # "Case Studies and Financial Modelling Course Notes," by
        # Jim Gatheral, Fall Term, 2003
        # see www.math.nyu.edu/fellows_fin_math/gatheral/Lecture1_Fall02.pdf
        # bug this class is untested, probably unreliable.
        LocalVolSurface(const Handle[BlackVolTermStructure]& blackTS,
                        Handle[YieldTermStructure] riskFreeTS,
                        Handle[YieldTermStructure] dividendTS,
                        Handle[Quote] underlying)
        LocalVolSurface(const Handle[BlackVolTermStructure]& blackTS,
                        Handle[YieldTermStructure] riskFreeTS,
                        Handle[YieldTermStructure] dividendTS,
                        Real underlying)
