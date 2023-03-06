from libcpp cimport bool
from quantlib.types cimport Real, Time
from cython.operator cimport dereference as deref
from . cimport _local_vol_surface as _lvs
from .black_vol_term_structure cimport BlackVolTermStructure
from . cimport _black_vol_term_structure as _bvts
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.quote cimport Quote
from quantlib.handle cimport static_pointer_cast, Handle
from quantlib.time.date cimport Date

cdef class LocalVolSurface(LocalVolTermStructure):
    def __init__(self, BlackVolTermStructure black_ts, YieldTermStructure risk_free_ts, YieldTermStructure dividend_ts, Quote underlying):
        """ Local volatility surface derived from a Black vol surface

        For details about this implementation refer to [Gat]_.

        Parameters
        ----------
        black_ts : BlackVolTermStructure
        risk_free_ts : YieldTermStructure
        dividend_ts : YieldTermStructure, the dividend term structure.
        underlying : Quote, the spot underlying

        .. [Gat] "Stochastic Volatility and LocalVolatility" in *Case Studies and Financial Modelling Course Notes,* Jim Gatheral, Fall Term, 2003 https://web.math.ku.dk/~rolf/teaching/ctff03/Gatheral.1.pdf
        """
        self._thisptr.reset(
            new _lvs.LocalVolSurface(
                Handle[_bvts.BlackVolTermStructure](static_pointer_cast[_bvts.BlackVolTermStructure](black_ts._thisptr)),
                risk_free_ts._thisptr,
                dividend_ts._thisptr,
                underlying.handle()
            )
        )

    def localVol(self, d, Real underlying_level, bool extrapolate=False):
        cdef _lvs.LocalVolSurface* surf = <_lvs.LocalVolSurface*>self._thisptr.get()
        if isinstance(d, float):
            return surf.localVol_(<Time>d, underlying_level, extrapolate)
        elif isinstance(d, Date):
            return surf.localVol(deref((<Date>d)._thisptr), underlying_level, extrapolate)
        else:
            raise TypeError("d needs to be either a Date or a Real")
