from ..quote cimport Quote
from . cimport _futuresconvadjustmentquote as _fcaq

cdef class FuturesConvAdjustmentQuote(Quote):
    cdef _fcaq.FuturesConvAdjustmentQuote* as_ptr(self)
