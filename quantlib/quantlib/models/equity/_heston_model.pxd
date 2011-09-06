# distutils: language = c++
# distutils: libraries = QuantLib


include '../../types.pxi'

from quantlib.handle cimport Handle
from quantlib.termstructures.yields._flat_forward cimport (
    YieldTermStructure, Quote
)
from quantlib.time._calendar cimport Calendar
from quantlib.time._period cimport Period

cdef extern from 'ql/models/equity/hestonmodelhelper.hpp' namespace 'QuantLib':

    cdef cppclass HestonModelHelper:
        HestonModelHelper(
            Period& maturity,
            Calendar& calendar,
            Real s0,
            Real strikePrice,
            Handle[Quote]& volatility,
            Handle[YieldTermStructure]& riskFreeRate,
            Handle[YieldTermStructure]& dividendYield,
        )



