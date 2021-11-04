from cython.operator cimport dereference as deref
from quantlib.handle cimport static_pointer_cast
from . cimport _overnightindexfuture as _oif
from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.indexes.ibor_index cimport OvernightIndex
cimport quantlib.indexes._ibor_index as _ii
from quantlib.quote cimport Quote
from quantlib.time.date cimport Date

cdef class OvernightIndexFuture(Instrument):
    """ Future on a compounded overnight index investment.

    Compatible with SOFR futures and Sonia futures available on
    CME and ICE exchanges.
    """
    def __init__(self, OvernightIndex overnight_index, Date value_date, Date maturity_date, Quote convexity_adjustment=Quote.__new__(Quote),
                 RateAveraging averaging_method=RateAveraging.Compound):
        self._thisptr.reset(
            new _oif.OvernightIndexFuture(
                static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                deref(value_date._thisptr),
                deref(maturity_date._thisptr),
                convexity_adjustment.handle(),
                averaging_method
            )
        )
