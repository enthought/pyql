from cython.operator cimport dereference as deref
from libcpp cimport bool
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time.date cimport Date
from ..cashflow cimport Leg
from ._cashflows cimport CashFlows

def previous_cash_flow_amount(Leg leg, bool include_settlement_date_flows, Date settlement_date=Date()):
    return CashFlows.previousCashFlowAmount(leg._thisptr, include_settlement_date_flows, settlement_date._thisptr)

def next_cash_flow_amount(Leg leg, bool include_settlement_date_flows, Date settlement_date=Date()):
    return CashFlows.nextCashFlowAmount(leg._thisptr, include_settlement_date_flows, settlement_date._thisptr)


def npv(Leg leg, YieldTermStructure discount_curve, bool include_settlement_date_flows,
        Date settlement_date=Date, Date npv_date=Date()):
    return CashFlows.npv(leg._thisptr,
                         deref(discount_curve.as_ptr()),
                         include_settlement_date_flows,
                         settlement_date._thisptr,
                         npv_date._thisptr)

def bps(Leg leg, YieldTermStructure discount_curve, bool include_settlement_date_flows,
        Date settlement_date=Date, Date npv_date=Date()):
    return CashFlows.bps(leg._thisptr,
                         deref(discount_curve.as_ptr()),
                         include_settlement_date_flows,
                         settlement_date._thisptr,
                         npv_date._thisptr)

def npvbps(Leg leg, YieldTermStructure discount_curve, bool include_settlement_date_flows,
        Date settlement_date=Date, Date npv_date=Date()):
    return CashFlows.npvbps(leg._thisptr,
                            deref(discount_curve.as_ptr()),
                            include_settlement_date_flows,
                            settlement_date._thisptr,
                            npv_date._thisptr)
