include '../types.pxi'

from libcpp cimport bool
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.indexes._swap_index cimport SwapIndex
from _floating_rate_coupon cimport FloatingRateCoupon

cdef extern from 'ql/cashflows/cmscoupon.hpp' namespace 'QuantLib':
    cdef cppclass CmsCoupon(FloatingRateCoupon):
        CmsCoupon(const Date& paymentDate,
                  Real nominal,
                  const Date& startDate,
                  const Date& endDate,
                  Natural fixingDays,
                  const shared_ptr[SwapIndex]& index,
                  Real gearing, # = 1.0,
                  Spread spread, # = 0.0,
                  const Date& refPeriodStart, # = Date(),
                  const Date& refPeriodEnd, # = Date(),
                  const DayCounter& dayCounter, #= DayCounter(),
                  bool isInArrears)
