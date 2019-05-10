include '../../types.pxi'

from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr, Handle

from quantlib._quote cimport Quote
from quantlib.instruments._bonds cimport Bond
from quantlib.termstructures._helpers cimport BootstrapHelper
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule
from ._flat_forward cimport YieldTermStructure
from ._rate_helpers cimport RateHelper


cdef extern from 'ql/termstructures/yield/bondhelpers.hpp' namespace 'QuantLib':

    cdef cppclass BondHelper(RateHelper):
        # this is added because of Cython. This empty constructor does not exist
        # and should never be used
        BondHelper()
        BondHelper(
            Handle[Quote]& cleanPrice,
            shared_ptr[Bond]& bond
            ) except +

    cdef cppclass FixedRateBondHelper(BondHelper):
        FixedRateBondHelper(
            Handle[Quote]& cleanPrice,
            Natural settlementDays,
            Real faceAmount,
            Schedule& schedule,
            vector[Rate]& coupons,
            DayCounter& dayCounter,
            int paymentConv,  # Following
            Real redemption,  # 100.0
            Date& issueDate  # Date()
        ) except +

