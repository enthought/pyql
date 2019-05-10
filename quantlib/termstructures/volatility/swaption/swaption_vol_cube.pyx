from . cimport _swaption_vol_cube as _svc
from libcpp.vector cimport vector
from quantlib.handle cimport Handle
from quantlib.time.date cimport Date, Period
from cython.operator cimport dereference as deref
cimport quantlib._quote as _qt
from quantlib.quotes cimport SimpleQuote

cdef inline _svc.SwaptionVolatilityCube* _get_svc(SwaptionVolatilityCube volcube):
    return <_svc.SwaptionVolatilityCube*> volcube._thisptr.get()


cdef class SwaptionVolatilityCube(SwaptionVolatilityDiscrete):
    def atm_strike(self, option_date not None,
                   Period swap_tenor not None):
        if isinstance(option_date, Date):
            return _get_svc(self).atmStrike(deref((<Date>option_date)._thisptr),
                                            deref(swap_tenor._thisptr))
        elif isinstance(option_date, Period):
            return _get_svc(self).atmStrike(deref((<Period>option_date)._thisptr),
                                            deref(swap_tenor._thisptr))

    def atm_vol(self):
        pass

    @property
    def strike_spreads(self):
        return _get_svc(self).strikeSpreads()

    @property
    def vol_spreads(self):
        cdef:
            vector[vector[Handle[_qt.Quote]]] m = _get_svc(self).volSpreads()
            vector[Handle[_qt.Quote]] row
            Handle[_qt.Quote] quote_handle
            list py_m = []
            list py_row
            SimpleQuote q
        for row in m:
            py_row = []
            for quote_handle in row:
                q = SimpleQuote.__new__(SimpleQuote)
                q._thisptr = quote_handle.currentLink()
                py_row.append(q)
            py_m.append(py_row)
        return py_m

    def swap_index_base(self):
        pass

    def short_swap_index_base(self):
        pass

    @property
    def vega_weighted_smile_fit(self):
        return _get_svc(self).vegaWeightedSmileFit()
