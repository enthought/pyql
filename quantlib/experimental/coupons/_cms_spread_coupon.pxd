include '../../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string
from quantlib.handle cimport shared_ptr, Handle
from quantlib.cashflows._floating_rate_coupon cimport FloatingRateCoupon
from quantlib.cashflows._coupon_pricer cimport FloatingRateCouponPricer
from quantlib.cashflows._cap_floored_coupon cimport CappedFlooredCoupon
from ._swap_spread_index cimport SwapSpreadIndex
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib._quote cimport Quote

cdef extern from 'ql/experimental/coupons/cmsspreadcoupon.hpp' namespace 'QuantLib':
    cdef cppclass CmsSpreadCoupon(FloatingRateCoupon):
        CmsSpreadCoupon(const Date& paymentDate,
                        Real nominal,
                        const Date& startDate,
                        const Date& endDate,
                        Natural fixingDays,
                        const shared_ptr[SwapSpreadIndex]& index,
                        Real gearing, # = 1.0,
                        Spread spread, #= 0.0,
                        const Date& refPeriodStart, # = Date(),
                        const Date& refPeriodEnd, # = Date(),
                        const DayCounter& dayCounter, # = DayCounter(),
                        bool isInArrears) # = false)
        shared_ptr[SwapSpreadIndex]& swapSpreadIndex()

    cdef cppclass CappedFlooredCmsSpreadCoupon(CappedFlooredCoupon):
        CappedFlooredCmsSpreadCoupon(
                  const Date& paymentDate,
                  Real nominal,
                  const Date& startDate,
                  const Date& endDate,
                  Natural fixingDays,
                  const shared_ptr[SwapSpreadIndex]& index,
                  Real gearing, #= 1.0,
                  Spread spread,# = 0.0,
                  const Rate cap, # = Null<Rate>(),
                  const Rate floor,# = Null<Rate>(),
                  const Date& refPeriodStart, # = Date(),
                  const Date& refPeriodEnd, # = Date(),
                  const DayCounter& dayCounter, # = DayCounter(),
                  bool isInArrears) except + # = false)

    cdef cppclass CmsSpreadCouponPricer(FloatingRateCouponPricer):
        CmsSpreadCouponPricer(const Handle& correlation) # = Handle[Quote](),

        void setCorrelation(const Handle[Quote] &correlation) # = Handle[Quote]()

        Handle[Quote] correlation() const
