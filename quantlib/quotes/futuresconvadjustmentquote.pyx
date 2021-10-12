from cython.operator cimport dereference as deref
from quantlib.handle cimport static_pointer_cast
from quantlib.time.date cimport Date
from quantlib.indexes.ibor_index cimport IborIndex
cimport quantlib.indexes._ibor_index as _ii
from . cimport _futuresconvadjustmentquote as _fcaq

cdef class FuturesConvAdjustmentQuote(Quote):
    def __init__(self, IborIndex index, Date futures_date,
                 Quote futures_quote,
                 Quote volatility,
                 Quote mean_reversion):
        self._thisptr.reset(
            new _fcaq.FuturesConvAdjustmentQuote(
                static_pointer_cast[_ii.IborIndex](index._thisptr),
                deref(futures_date._thisptr),
                futures_quote.handle(),
                volatility.handle(),
                mean_reversion.handle()
            )
        )
