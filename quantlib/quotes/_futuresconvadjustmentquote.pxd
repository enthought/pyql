from libcpp.string cimport string
from quantlib.handle cimport Handle, shared_ptr
from quantlib.types cimport Real
from quantlib.time._date cimport Date
from quantlib.indexes._ibor_index cimport IborIndex
from .._quote cimport Quote

cdef extern from 'ql/quotes/futuresconvadjustmentquote.hpp' namespace 'QuantLib' nogil:
    cdef cppclass FuturesConvAdjustmentQuote(Quote):
            FuturesConvAdjustmentQuote(const shared_ptr[IborIndex]& index,
                                       const Date& futuresDate,
                                       Handle[Quote] futuresQuote,
                                       Handle[Quote] volatility,
                                       Handle[Quote] meanReversion)
            FuturesConvAdjustmentQuote(const shared_ptr[IborIndex]& index,
                                       const string& immCode,
                                       Handle[Quote] futuresQuote,
                                       Handle[Quote] volatility,
                                       Handle[Quote] meanReversion)
            Real futuresValue()
            Real volatility()
            Real meanReversion()
            Date immDate()
