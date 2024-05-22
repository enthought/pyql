from quantlib.types cimport Real, Spread
from cython.operator cimport dereference as deref
from quantlib.instruments.swap cimport Swap
from quantlib.handle cimport static_pointer_cast, shared_ptr
from quantlib.indexes.swap_index cimport SwapIndex
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.time.date cimport Period, Date
from quantlib.time._period cimport Days
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
cimport quantlib.indexes._swap_index as _si
cimport quantlib.indexes._ibor_index as _ii
cimport quantlib._instrument as _in
cimport quantlib.instruments._swap as _swap

cdef class MakeCms:
    def __init__(self, Period swap_tenor not None,
                 SwapIndex swap_index not None,
                 IborIndex ibor_index=None,
                 Spread ibor_spread=0.,
                 Period forward_start=Period(0, Days)):
        if ibor_index is None:
            self._thisptr = new _make_cms.MakeCms(
                deref(swap_tenor._thisptr),
                static_pointer_cast[_si.SwapIndex](swap_index._thisptr),
                ibor_spread,
                deref(forward_start._thisptr)
            )
        else:
            self._thisptr = new _make_cms.MakeCms(
                deref(swap_tenor._thisptr),
                static_pointer_cast[_si.SwapIndex](swap_index._thisptr),
                static_pointer_cast[_ii.IborIndex](ibor_index._thisptr),
                ibor_spread,
                deref(forward_start._thisptr)
            )

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __call__(self):
        cdef Swap instance = Swap.__new__(Swap)
        cdef shared_ptr[_swap.Swap] temp = <shared_ptr[_swap.Swap]>deref(self._thisptr)
        instance._thisptr = static_pointer_cast[_in.Instrument](temp)
        return instance

    def with_nominal(self, Real n):
        self._thisptr.withNominal(n)
        return self

    def with_effective_date(self, Date effective_date not None):
        self._thisptr.withEffectiveDate(effective_date._thisptr)
        return self

    def with_discounting_term_structure(self, YieldTermStructure discounting_term_structure not None):
        self._thisptr.withDiscountingTermStructure(
            discounting_term_structure._thisptr)
        return self

    def with_cms_leg_tenor(self, Period t not None):
        self._thisptr.withCmsLegTenor(deref(t._thisptr))
        return self
