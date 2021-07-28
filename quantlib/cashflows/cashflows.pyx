from cython.operator cimport dereference as deref
from libcpp cimport bool
from quantlib.time.date cimport Date
from ..cashflow cimport Leg
from ._cashflows cimport CashFlows

def previous_cash_flow_amount(Leg leg, bool include_settlement_date_flows, Date settlement_date=Date()):
    return CashFlows.previousCashFlowAmount(leg._thisptr, include_settlement_date_flows, deref(settlement_date._thisptr))

def next_cash_flow_amount(Leg leg, bool include_settlement_date_flows, Date settlement_date=Date()):
    return CashFlows.nextCashFlowAmount(leg._thisptr, include_settlement_date_flows, deref(settlement_date._thisptr))
