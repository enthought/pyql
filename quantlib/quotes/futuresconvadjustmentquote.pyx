from libcpp.string cimport string
from cython.operator cimport dereference as deref
from quantlib.ext cimport static_pointer_cast
from quantlib.time.date cimport Date, _pydate_from_qldate
from quantlib.indexes.ibor_index cimport IborIndex
cimport quantlib.indexes._ibor_index as _ii

cdef class FuturesConvAdjustmentQuote(Quote):
    """Quote for the futures-convexity adjustment of an index.

    Parameters
    ----------
    index : :class:`~quantlib.indexes.ibor_index.IborIndex`
        The underlying IBOR index.
    futures_date_or_code : :class:`~quantlib.time.date.Date` or str
        The futures date or IMM code.
    futures_quote : :class:`~quantlib.quote.Quote`
        The quote for the futures contract.
    volatility : :class:`~quantlib.quote.Quote`
        The volatility quote.
    mean_reversion : :class:`~quantlib.quote.Quote`
        The mean-reversion quote.
    """
    def __init__(self, IborIndex index, futures_date_or_code,
                 Quote futures_quote,
                 Quote volatility,
                 Quote mean_reversion):
        if isinstance(futures_date_or_code, Date):
            self._thisptr.reset(
                new _fcaq.FuturesConvAdjustmentQuote(
                    static_pointer_cast[_ii.IborIndex](index._thisptr),
                    (<Date>futures_date_or_code)._thisptr,
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
        """The value of the futures quote."""
        return self.as_ptr().futuresValue()

    @property
    def volatility(self):
        """The volatility of the quote."""
        return self.as_ptr().volatility()

    @property
    def mean_reversion(self):
        """The mean reversion of the quote."""
        return self.as_ptr().meanReversion()

    @property
    def imm_date(self):
        """The IMM date of the futures contract."""
        return _pydate_from_qldate(self.as_ptr().immDate())
