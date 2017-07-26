include 'types.pxi'

cimport _cashflow as _cf

from quantlib.handle cimport shared_ptr
from libcpp.vector cimport vector

cdef class CashFlow:
    cdef shared_ptr[_cf.CashFlow]* _thisptr

cdef class SimpleCashFlow(CashFlow):
    pass

cdef class Leg:
    cdef _cf.Leg _thisptr

cdef list leg_items(const _cf.Leg& leg)
