from libcpp.string cimport string
from cython.operator cimport dereference as deref
from quantlib.handle cimport static_pointer_cast
from quantlib.time.date cimport Date, _pydate_from_qldate
from quantlib.indexes.ibor_index cimport IborIndex
cimport quantlib.indexes._ibor_index as _ii

cdef class FuturesConvAdjustmentQuote(Quote):
    def __init__(self, IborIndex index, futures_date_or_code,
                 Quote futures_quote,
                 Quote volatility,
                 Quote mean_reversion):
        if isinstance(futures_date_or_code, Date):
            self._thisptr.reset(
                new _fcaq.FuturesConvAdjustmentQuote(
                    static_pointer_cast[_ii.IborIndex](index._thisptr),
                    deref((<Date>futures_date_or_code)._thisptr),
                    futures_quote.handle(),
                    volatility.handle(),
                    mean_reversion.handle()
                )
            )
        elif isinstance(futures_date_or_code, str):
            self._thisptr.reset(
                new _fcaq.FuturesConvAdjustmentQuote(
                    static_pointer_cast[_ii.IborIndex](index._thisptr),
                    <string>futures_date_or_code.encode(),
                    futures_quote.handle(),
                    volatility.handle(),
                    mean_reversion.handle()
                )
            )

    cdef inline _fcaq.FuturesConvAdjustmentQuote* as_ptr(self):
        return <_fcaq.FuturesConvAdjustmentQuote*>self._thisptr.get()

    @property
    def futures_value(self):
        return self.as_ptr().futuresValue()

    @property
    def volatility(self):
        return self.as_ptr().volatility()

    @property
    def mean_reversion(self):
        return self.as_ptr().meanReversion()

    @property
    def imm_date(self):
        return _pydate_from_qldate(self.as_ptr().immDate())
