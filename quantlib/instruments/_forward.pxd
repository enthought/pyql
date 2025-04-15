from libcpp cimport bool
from quantlib.compounding cimport Compounding
from quantlib._instrument cimport Instrument
from quantlib._interest_rate cimport InterestRate
from quantlib.types cimport Real
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

from quantlib.handle cimport Handle

cdef extern from "ql/instruments/forward.hpp" namespace "QuantLib" nogil:
    cdef cppclass Forward(Instrument):
        Date settlementDate() const
        const Calendar& calendar() const
        BusinessDayConvention businessDayConvention() const
        const DayCounter& dayCounter() const
        # term structure relevant to the contract (e.g. repo curve)
        Handle[YieldTermStructure] discountCurve() const
        # term structure that discounts the underlying's income cash flows
        Handle[YieldTermStructure] incomeDiscountCurve() const
        # returns whether the instrument is still tradable
        bool isExpired() const

        # returns spot value/price of an underlying financial instrument
        Real spotValue() const
        # NPV of income/dividends/storage-costs etc. of underlying instrument
        Real spotIncome(const Handle[YieldTermStructure]&
                        incomeDiscountCurve) const

        # forward value/price of underlying, discounting income/dividends
        # \note if this is a bond forward price, is must be a dirty
        #       forward price.
        Real forwardValue() const

        # Simple yield calculation based on underlying spot and
            # forward values, taking into account underlying income.
            # When \f$ t>0 \f$, call with:
            # underlyingSpotValue=spotValue(t),
            # forwardValue=strikePrice, to get current yield. For a
            # repo, if \f$ t=0 \f$, impliedYield should reproduce the
            # spot repo rate. For FRA's, this should reproduce the
            # relevant zero rate at the FRA's maturityDate_
        InterestRate impliedYield(Real underlyingSpotValue,
                                  Real forwardValue,
                                  Date settlementDate,
                                  Compounding compoundingConvention,
                                  const DayCounter& dayCounter)
