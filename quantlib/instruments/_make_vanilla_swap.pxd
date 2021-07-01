include '../types.pxi'

from libcpp cimport bool
from quantlib.handle cimport shared_ptr, Handle
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time._calendar cimport Calendar
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time._schedule cimport Rule
from quantlib.time._daycounter cimport DayCounter
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.instruments._vanillaswap cimport VanillaSwap
from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/instruments/makevanillaswap.hpp' namespace 'QuantLib':
    cdef cppclass MakeVanillaSwap:
        MakeVanillaSwap(const Period& swapTenor,
                        const shared_ptr[IborIndex]& iborIndex,
                        Rate fixedRate, # = Null<Rate>())
                        const Period& forwardStart) #= 0*Days)

        VanillaSwap operator()
        shared_ptr[VanillaSwap] operator()

        MakeVanillaSwap& receiveFixed(bool flag) # = true);
        MakeVanillaSwap& withType(VanillaSwap.Type type)
        MakeVanillaSwap& withNominal(Real n)

        MakeVanillaSwap& withSettlementDays(Natural settlementDays)
        MakeVanillaSwap& withEffectiveDate(const Date&)
        MakeVanillaSwap& withTerminationDate(const Date&)
        MakeVanillaSwap& withRule(Rule r)

        MakeVanillaSwap& withFixedLegTenor(const Period& t)
        MakeVanillaSwap& withFixedLegCalendar(const Calendar& cal)
        MakeVanillaSwap& withFixedLegConvention(BusinessDayConvention bdc)
        MakeVanillaSwap& withFixedLegTerminationDateConvention(
                                                   BusinessDayConvention bdc)
        MakeVanillaSwap& withFixedLegRule(Rule r)
        MakeVanillaSwap& withFixedLegEndOfMonth(bool flag) # = true)
        MakeVanillaSwap& withFixedLegFirstDate(const Date& d)
        MakeVanillaSwap& withFixedLegNextToLastDate(const Date& d)
        MakeVanillaSwap& withFixedLegDayCount(const DayCounter& dc)

        MakeVanillaSwap& withFloatingLegTenor(const Period& t)
        MakeVanillaSwap& withFloatingLegCalendar(const Calendar& cal)
        MakeVanillaSwap& withFloatingLegConvention(BusinessDayConvention bdc)
        MakeVanillaSwap& withFloatingLegTerminationDateConvention(
                                                   BusinessDayConvention bdc)
        MakeVanillaSwap& withFloatingLegRule(Rule r)
        MakeVanillaSwap& withFloatingLegEndOfMonth(bool flag)# = true)
        MakeVanillaSwap& withFloatingLegFirstDate(const Date& d)
        MakeVanillaSwap& withFloatingLegNextToLastDate(const Date& d)
        MakeVanillaSwap& withFloatingLegDayCount(const DayCounter& d)
        MakeVanillaSwap& withFloatingLegSpread(Spread sp)

        MakeVanillaSwap& withDiscountingTermStructure(
            const Handle[YieldTermStructure]& discountCurve)
        MakeVanillaSwap& withPricingEngine(
            const shared_ptr[PricingEngine]& engine);
