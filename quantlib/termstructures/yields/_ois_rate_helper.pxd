include '../../types.pxi'

from libcpp cimport bool

from quantlib._quote cimport Quote
from quantlib.handle cimport shared_ptr, Handle
from quantlib.time._period cimport Period, Frequency
from quantlib.termstructures.yields._rate_helpers cimport RelativeDateRateHelper
from quantlib.indexes._ibor_index cimport OvernightIndex
from quantlib.time._calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention

cimport quantlib.termstructures._yield_term_structure as _yts

cdef extern from 'ql/termstructures/yield/oisratehelper.hpp' namespace 'QuantLib':
    cdef cppclass OISRateHelper(RelativeDateRateHelper):
        OISRateHelper(Natural settlementDays,
                      Period& tenor, # swap maturity
                      Handle[Quote]& fixedRate,
                      shared_ptr[OvernightIndex]& overnightIndex,
                      # exogenous discounting curve
                      Handle[_yts.YieldTermStructure]& discountingCurve, # = Handle<YieldTermStructure>()
                      bool telescopicValueDates, # False)
                      Natural paymentLag, # = 0
                      BusinessDayConvention paymentConvention, # = Following
                      Frequency paymentFrequency, #  = Annual
                      Calendar& paymentCalendar, # = Calendar()
                      Period& forwardStart, # = 0 * Days
                      Spread overnightSpread) except + # = 0.0
