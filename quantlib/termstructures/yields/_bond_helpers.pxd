include '../../types.pxi'

from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, Handle
from quantlib._quote cimport Quote
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._schedule cimport Schedule

# from quantlib.termstructures.yields._rate_helpers import RateHelper
from quantlib.instruments._bonds cimport Bond

from quantlib.termstructures._helpers cimport BootstrapHelper
from _flat_forward cimport YieldTermStructure


cdef extern from 'ql/termstructures/yield/bondhelpers.hpp' namespace 'QuantLib':

    # FIXME: This is duplicated from _rate_helpers.pxd
    ctypedef BootstrapHelper[YieldTermStructure] RateHelper

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
