from quantlib.types cimport Real, Spread
from libcpp cimport bool
from quantlib.handle cimport shared_ptr
from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.instruments._swap cimport Swap
from quantlib.cashflows._coupon_pricer cimport CmsCouponPricer
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time.dategeneration cimport DateGeneration
from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/instruments/makecms.hpp' namespace 'QuantLib':
    cdef cppclass MakeCms:
        MakeCms(const Period& swapTenor,
                const shared_ptr[SwapIndex]& swapIndex,
                const shared_ptr[IborIndex]& iborIndex,
                Spread iborSpread, # = 0.0,
                const Period& forwardStart) # = 0*Days)
        MakeCms(const Period& swapTenor,
                const shared_ptr[SwapIndex]& swapIndex,
                Spread iborSpread, # = 0.0,
                const Period& forwardStart) # = 0*Days)
        shared_ptr[Swap] operator()
        MakeCms& receiveCms(bool flag = true);
        MakeCms& withNominal(Real n)
        MakeCms& withEffectiveDate(const Date&)

        MakeCms& withCmsLegTenor(const Period& t)
        MakeCms& withCmsLegCalendar(const Calendar& cal)
        MakeCms& withCmsLegConvention(BusinessDayConvention bdc)
        MakeCms& withCmsLegTerminationDateConvention(BusinessDayConvention)
        MakeCms& withCmsLegRule(DateGeneration r)
        MakeCms& withCmsLegEndOfMonth(bool flag = True)
        MakeCms& withCmsLegFirstDate(const Date& d)
        MakeCms& withCmsLegNextToLastDate(const Date& d)
        MakeCms& withCmsLegDayCount(const DayCounter& dc)

        MakeCms& withFloatingLegTenor(const Period& t)
        MakeCms& withFloatingLegCalendar(const Calendar& cal)
        MakeCms& withFloatingLegConvention(BusinessDayConvention bdc)
        MakeCms& withFloatingLegTerminationDateConvention(
                                                    BusinessDayConvention bdc)
        MakeCms& withFloatingLegRule(DateGeneration r)
        MakeCms& withFloatingLegEndOfMonth(bool flag = True)
        MakeCms& withFloatingLegFirstDate(const Date& d)
        MakeCms& withFloatingLegNextToLastDate(const Date& d)
        MakeCms& withFloatingLegDayCount(const DayCounter& dc)

        MakeCms& withAtmSpread(bool flag = True)

        MakeCms& withDiscountingTermStructure(
            Handle[YieldTermStructure]& discountingTermStructure)
        MakeCms& withCmsCouponPricer(
            shared_ptr[CmsCouponPricer]& couponPricer)
