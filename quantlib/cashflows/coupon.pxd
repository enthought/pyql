from quantlib.cashflow cimport CashFlow
cimport quantlib.cashflows._coupon as _coupon

cdef class Coupon(CashFlow):
    cdef inline _coupon.Coupon* _get_coupon(self)
