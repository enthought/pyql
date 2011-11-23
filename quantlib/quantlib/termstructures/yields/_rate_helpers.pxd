include '../../types.pxi'

from libcpp cimport bool

from quantlib.handle cimport Handle
from quantlib._quote cimport Quote
from quantlib.time._calendar cimport BusinessDayConvention, Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period
from _flat_forward cimport YieldTermStructure

cdef extern from 'ql/termstructures/bootstraphelper.hpp' namespace 'QuantLib':

    cdef cppclass BootstrapHelper[T]:
        BootstrapHelper(Handle[Quote]& quote)
        BoostrapHelper(Real quote)

cdef extern from 'ql/termstructures/yield/ratehelpers.hpp' namespace 'QuantLib':

    # Cython does not support this ctypedef - thus trying to expose a class
    #ctypedef BootstrapHelper[YieldTermStructure] RateHelper
    cdef cppclass RateHelper:
        Handle[Quote] quote()


    cdef cppclass DepositRateHelper(RateHelper):
        DepositRateHelper(Handle[Quote]& rate,
                          Period& tenor,
                          Natural fixingDays,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter)
        DepositRateHelper(Rate rate,
                          Period& tenor,
                          Natural fixingDays,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter)

        # Not supporting IborIndex at this stage
        #DepositRateHelper(const Handle<Quote>& rate,
        #                  const boost::shared_ptr<IborIndex>& iborIndex);
        #DepositRateHelper(Rate rate,
        #                  const boost::shared_ptr<IborIndex>& iborIndex);


