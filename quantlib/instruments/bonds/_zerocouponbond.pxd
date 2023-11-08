from quantlib.types cimport Natural, Real
from .._bond cimport Bond
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time.businessdayconvention cimport BusinessDayConvention

cdef extern from 'ql/instruments/bonds/zerocouponbond.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ZeroCouponBond(Bond):
        ZeroCouponBond(Natural settlementDays,
                       Calendar calendar,
                       Real faceAmount,
                       Date maturityDate,
                       BusinessDayConvention paymentConvention,
                       Real redemption,
                       Date& issueDate) except +
