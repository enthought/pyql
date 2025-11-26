from cython.operator cimport dereference as deref
from libcpp cimport bool
from quantlib.ext cimport optional, nullopt
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time.date cimport Date, _pydate_from_qldate
from quantlib.time._date cimport Date as QlDate
from ..cashflow cimport Leg
from ._cashflows cimport CashFlows

def previous_cash_flow_amount(Leg leg, include_settlement_date_flows=None, Date settlement_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    return CashFlows.previousCashFlowAmount(leg._thisptr, include_settlement_date_flows_opt.value(), settlement_date._thisptr)

def next_cash_flow_amount(Leg leg, include_settlement_date_flows=None, Date settlement_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    return CashFlows.nextCashFlowAmount(leg._thisptr, include_settlement_date_flows_opt.value(), settlement_date._thisptr)


def npv(Leg leg, YieldTermStructure discount_curve, include_settlement_date_flows=None,
        Date settlement_date=Date(), Date npv_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows

    return CashFlows.npv(leg._thisptr,
                         deref(discount_curve.as_yts_ptr()),
                         include_settlement_date_flows_opt.value(),
                         settlement_date._thisptr,
                         npv_date._thisptr)

def bps(Leg leg, YieldTermStructure discount_curve, include_settlement_date_flows=None,
        Date settlement_date=Date(), Date npv_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    return CashFlows.bps(leg._thisptr,
                         deref(discount_curve.as_yts_ptr()),
                         include_settlement_date_flows_opt.value(),
                         settlement_date._thisptr,
                         npv_date._thisptr)

def npvbps(Leg leg, YieldTermStructure discount_curve, include_settlement_date_flows=None,
        Date settlement_date=Date(), Date npv_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    return CashFlows.npvbps(leg._thisptr,
                            deref(discount_curve.as_yts_ptr()),
                            include_settlement_date_flows_opt.value(),
                            settlement_date._thisptr,
                            npv_date._thisptr)


def accrual_start_date(Leg leg, include_settlement_date_flows=None,
                       Date settlement_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    cdef QlDate d
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    d = CashFlows.accrualStartDate(leg._thisptr,
                                   include_settlement_date_flows_opt.value(),
                                   settlement_date._thisptr)
    return _pydate_from_qldate(d)

def accrual_end_date(Leg leg, include_settlement_date_flows=None,
                     Date settlement_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    d = CashFlows.accrualEndDate(leg._thisptr,
                                 include_settlement_date_flows_opt.value(),
                                 settlement_date._thisptr)
    return _pydate_from_qldate(d)


def accrual_days(Leg leg, include_settlement_date_flows=None,
                 Date settlement_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    return CashFlows.accrualDays(leg._thisptr,
                                 include_settlement_date_flows_opt.value(),
                                 settlement_date._thisptr)

def accrued_days(Leg leg, include_settlement_date_flows=None,
                 Date settlement_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    return CashFlows.accruedDays(leg._thisptr,
                                 include_settlement_date_flows_opt.value(),
                                 settlement_date._thisptr)

def accrued_amount(Leg leg, include_settlement_date_flows=None,
                   Date settlement_date=Date()):
    cdef optional[bool] include_settlement_date_flows_opt = nullopt
    if include_settlement_date_flows is not None:
        include_settlement_date_flows_opt = <bool>include_settlement_date_flows
    return CashFlows.accruedAmount(leg._thisptr,
                                   include_settlement_date_flows_opt.value(),
                                   settlement_date._thisptr)
