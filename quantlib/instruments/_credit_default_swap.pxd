include '../types.pxi'

from libcpp cimport bool
from quantlib.handle cimport optional, Handle, shared_ptr
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from ._instrument cimport Instrument
from quantlib._cashflow cimport Leg
from quantlib.time._calendar cimport BusinessDayConvention
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule

cdef extern from 'ql/default.hpp' namespace 'QuantLib::Protection':
    enum Side:
        Buyer
        Seller

cdef extern from 'ql/instruments/creditdefaultswap.hpp' namespace 'QuantLib::CreditDefaultSwap':
    enum PricingModel:
        Midpoint
        ISDA

cdef extern from 'ql/instruments/claim.hpp' namespace 'QuantLib':

    cdef cppclass Claim:
        Claim()

cdef extern from 'ql/instruments/creditdefaultswap.hpp' namespace 'QuantLib':

    cdef cppclass CreditDefaultSwap(Instrument):
        CreditDefaultSwap(Side side,
                          Real notional,
                          Rate spread,
                          Schedule& schedule,
                          BusinessDayConvention paymentConvention,
                          DayCounter& dayCounter,
                          bool settlesAccrual, # = true,
                          bool paysAtDefaultTime, # = true,
                          Date& protectionStart, #= Date(),
                          shared_ptr[Claim]&, # = boost::shared_ptr<Claim>(),
                          DayCounter& last_period_day_counter, # = DayCounter()
                          bool rebates_accrual # = true
        )
        CreditDefaultSwap(Side side,
                          Real notional,
                          Rate upfront,
                          Rate spread,
                          Schedule& schedule,
                          BusinessDayConvention paymentConvention,
                          DayCounter& dayCounter,
                          bool settlesAccrual, # = true,
                          bool paysAtDefaultTime, # = true,
                          Date& protectionStart, #= Date(),
                          Date& upfrontDate, #=Date(),
                          shared_ptr[Claim]&, # = boost::shared_ptr<Claim>(),
                          DayCounter& last_period_day_counter, # = DayCounter()
                          bool rebates_accrual # = true
                          ) except +
        int side()
        Real notional()
        Rate runningSpread()
        optional[Rate] upfront()
        bool settlesAccrual()
        bool paysAtDefaultTime()
        const Leg& coupons()
        const Date& protectionStartDate()
        const Date& protectionEndDate()
        bool rebatesAccrual()

        Rate fairUpfront() except +
        Rate fairSpread() except +
        Real couponLegBPS() except +
        Real upfrontBPS() except +
        Real couponLegNPV() except +
        Real defaultLegNPV() except +
        Real upfrontNPV() except +
        Real accrualRebateNPV() except +

        Rate conventionalSpread(Real conventionalRecovery,
                                Handle[YieldTermStructure]& discountCurve,
                                const DayCounter dayCounter,
                                bool useIsdaEngine # = false
        ) except +
        Rate impliedHazardRate(Real targetNPV,
                               const Handle[YieldTermStructure]& discountCurve,
                               const DayCounter dayCounter,
                               Real recoveryRate, # = 0.4,
                               Real accuracy, # = 1.0e-8
                               PricingModel model # = Midpoint
        ) except +
