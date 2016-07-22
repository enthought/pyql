"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""


include '../../types.pxi'
from libcpp cimport bool

from quantlib.handle cimport Handle, shared_ptr
from quantlib._quote cimport Quote
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period, Frequency
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure
from quantlib.time._schedule cimport Rule

from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.termstructures._helpers cimport BootstrapHelper, \
                                              RelativeDateBootstrapHelper
from quantlib.instruments._credit_default_swap cimport CreditDefaultSwap

cdef extern from 'ql/termstructures/credit/defaultprobabilityhelpers.hpp' namespace 'QuantLib':

    ctypedef BootstrapHelper[DefaultProbabilityTermStructure] DefaultProbabilityHelper
    ctypedef RelativeDateBootstrapHelper[DefaultProbabilityTermStructure] \
                                         RelativeDateDefaultProbabilityHelper

    cdef cppclass CdsHelper(RelativeDateDefaultProbabilityHelper):
        CdsHelper() # empty constructor added for Cython
        CdsHelper(Handle[Quote]& quote, Period& tenor,
                  Integer settlementDays,
                  Calendar& calendar,
                  Frequency frequency,
                  BusinessDayConvention paymentConvention,
                  Rule rule,
                  DayCounter& dayCounter,
                  Real recoveryRate,
                  Handle[YieldTermStructure]& discountCurve,
                  bool settlesAccrual, # removed default value (true)
                  bool paysADefaultTime, # removed default value (true)
                  DayCounter lastPeriodDayCounter,
                  bool rebatesAccrual, # removed default value (true)
                  bool useIsdaEngine) # removed default value (false)

        void setTermStructure(DefaultProbabilityTermStructure*)
        void setIsdaEngineParameters(int numericalFix,
                                     int accrualBias,
                                     int forwardsInCouponPeriod)
        const shared_ptr[CreditDefaultSwap]& swap()

    cdef cppclass SpreadCdsHelper(CdsHelper):
        SpreadCdsHelper(Rate runningSpread,
                        const Period& tenor,
                        Integer settlementDays,
                        const Calendar& calendar,
                        Frequency frequency,
                        BusinessDayConvention paymentConvention,
                        Rule rule,
                        const DayCounter& dayCounter,
                        Real recoveryRate,
                        const Handle[YieldTermStructure]& discountCurve,
                        bool settlesAccrual,  # removed default value (true)
                        bool paysAtDefaultTime, # removed default value (true)
                        const DayCounter lastPeriodDayCounter,
                        bool rebatesAccrual, # removed default value (true)
                        bool useIsdaEngine) # removed default value (false)

        SpreadCdsHelper(const Handle[Quote]& runningSpread,
                        const Period& tenor,
                        Integer settlementDays,
                        const Calendar& calendar,
                        Frequency frequency,
                        BusinessDayConvention paymentConvention,
                        Rule rule,
                        const DayCounter& dayCounter,
                        Real recoveryRate,
                        const Handle[YieldTermStructure]& discountCurve,
                        bool settlesAccrual,  # removed default value (true)
                        bool paysAtDefaultTime, # removed default value (true)
                        const DayCounter lastPeriodDayCounter,
                        bool rebatesAccrual, # removed default value (true)
                        bool useIsdaEngine) # removed default value (false)

    cdef cppclass UpfrontCdsHelper(CdsHelper):
        UpfrontCdsHelper(Rate upfront,
                         Rate runningSpread,
                         const Period& tenor,
                         Integer settlementDays,
                         const Calendar& calendar,
                         Frequency frequency,
                         BusinessDayConvention paymentConvention,
                         Rule rule,
                         const DayCounter& dayCounter,
                         Real recoveryRate,
                         const Handle[YieldTermStructure]& discountCurve,
                         Natural upfrontSettlementDays,
                         bool settlesAccrual,  # removed default value (true)
                         bool paysAtDefaultTime, # removed default value (true)
                         const DayCounter& lastPeriodDayCounter,
                         bool rebatesAccrual, # removed default value (true)
                         bool useIsdaEngine # removed default value (false)
                         ) except +

        UpfrontCdsHelper(const Handle[Quote]& upfront,
                         Rate runningSpread,
                         const Period& tenor,
                         Integer settlementDays,
                         const Calendar& calendar,
                         Frequency frequency,
                         BusinessDayConvention paymentConvention,
                         Rule rule,
                         const DayCounter& dayCounter,
                         Real recoveryRate,
                         const Handle[YieldTermStructure]& discountCurve,
                         Natural upfrontSettlementDays,
                         bool settlesAccrual,  # removed default value (true)
                         bool paysAtDefaultTime, # removed default value (true)
                         const DayCounter& lastPeriodDayCounter,
                         bool rebatesAccrual, # removed default value (true)
                         bool useIsdaEngine # removed default value (false)
                         ) except +
