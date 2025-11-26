from libcpp cimport bool
from libcpp.pair cimport pair
#from quantlib.ext cimport optional
from quantlib.time._date cimport Date
from quantlib.types cimport Rate, Real
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from .._cashflow cimport Leg

cdef extern from 'ql/cashflows/cashflows.hpp' namespace 'QuantLib' nogil:
    cdef cppclass CashFlows:
        @staticmethod
        Date startDate(const Leg& leg)

        @staticmethod
        Date maturityDate(const Leg& leg)

        @staticmethod
        bool isExpired(const Leg& leg,
                       #optional[bool] includeSettlementDateFlows, # = nullopt
                       bool includeSettlementDateFlows,
                       Date settlementDate) # = Date()

        @staticmethod
        Date previousCashFlowDate(const Leg& leg,
                                  # optional[bool] includeSettlementDateFlows, # = nullopt
                                  bool includeSettlementDateFlows,
                                  Date settlementDate)# = Date())

        @staticmethod
        Date nextCashFlowDate(const Leg& leg,
                              #optional[bool] includeSettlementDateFlows, # = nullopt
                              bool includeSettlementDateFlows,
                              Date settlementDate)# = Date())

        @staticmethod
        Real previousCashFlowAmount(const Leg& leg,
                                    #optional[bool] includeSettlementDateFlows, # = nullopt
                                    bool includeSettlementDateFlows,
                                    Date settlementDate)# = Date())
        @staticmethod
        Real nextCashFlowAmount(const Leg& leg,
                                #optional[bool] includeSettlementDateFlows, # = nullopt
                                bool includeSettlementDateFlows,
                                Date settlementDate)# = Date())
        # static Rate
        # previousCouponRate(const Leg& leg,
        #                    bool includeSettlementDateFlows,
        #                    Date settlementDate = Date());
        # static Rate
        # nextCouponRate(const Leg& leg,
        #                bool includeSettlementDateFlows,
        #                Date settlementDate = Date());

        # static Real
        # nominal(const Leg& leg,
        #         bool includeSettlementDateFlows,
        #         Date settlDate = Date());
        @staticmethod
        Date accrualStartDate(const Leg& leg,
                              #optional[bool] includeSettlementDateFlows, # = nullopt
                              bool includeSettlementDateFlows,
                              Date settlDate) # = Date()
        @staticmethod
        Date accrualEndDate(const Leg& leg,
                            #optional[bool] includeSettlementDateFlows, # = nullopt
                            bool includeSettlementDateFlows,
                            Date settlementDate) # = Date()
        # static Date
        # referencePeriodStart(const Leg& leg,
        #                      bool includeSettlementDateFlows,
        #                      Date settlDate = Date());
        # static Date
        # referencePeriodEnd(const Leg& leg,
        #                    bool includeSettlementDateFlows,
        #                    Date settlDate = Date());
        # static Time
        # accrualPeriod(const Leg& leg,
        #               bool includeSettlementDateFlows,
        #               Date settlementDate = Date());
        @staticmethod
        Date.serial_type accrualDays(const Leg& leg,
                                     #optional[bool] includeSettlementDateFlows, # = nullopt
                                     bool includeSettlementDateFlows,
                                     Date settlementDate) # = Date()
        # static Time
        # accruedPeriod(const Leg& leg,
        #               bool includeSettlementDateFlows,
        #               Date settlementDate = Date());
        @staticmethod
        Date.serial_type accruedDays(const Leg& leg,
                                     #optional[bool] includeSettlementDateFlows, # = nullopt
                                     bool includeSettlementDateFlows,
                                     Date settlementDate) # = Date()
        @staticmethod
        Real accruedAmount(const Leg& leg,
                           # optional[bool] includeSettlementDateFlows, # =nullopt
                           bool includeSettlementDateFlows,
                           Date settlementDate) # = Date()
        @staticmethod
        Real npv(const Leg& leg,
                 const YieldTermStructure& discountCurve,
                 #optional[bool] includeSettlementDateFlows, # = nullopt
                 bool includeSettlementDateFlows,
                 Date settlementDate, # = Date(),
                 Date npvDate) # = Date())

        @staticmethod
        Real bps(const Leg& leg,
                 const YieldTermStructure& discountCurve,
                 #optional[bool] includeSettlementDateFlows, # = nullopt
                 bool includeSettlementDateFlows,
                 Date settlementDate, # = Date(),
                 Date npvDate) # = Date())

        @staticmethod
        pair[Real, Real] npvbps(const Leg& leg,
                                const YieldTermStructure& discountCurve,
                                #optional[bool] includeSettlementDateFlows, # = nullopt
                                bool includeSettlementDateFlows,
                                Date settlementDate, # = Date(),
                                Date npvDate) #= Date())
