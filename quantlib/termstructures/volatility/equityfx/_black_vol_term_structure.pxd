include '../../../types.pxi'
from libcpp cimport bool

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.termstructures._vol_term_structure cimport VolatilityTermStructure

cdef extern from 'ql/termstructures/volatility/equityfx/blackvoltermstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass BlackVolTermStructure(VolatilityTermStructure):
        # Constructors
        #    See the TermStructure documentation for issues regarding
        #    constructors.
        #
        # default constructor
        # warning term structures initialized by means of this
        #     constructor must manage their own reference date
        #     by overriding the referenceDate() method.
        BlackVolTermStructure(BusinessDayConvention bdc, #= Following,
                              DayCounter& dc) except +
        # initialize with a fixed reference date
        BlackVolTermStructure(Date& referenceDate,
                              Calendar& cal, #= Calendar(),
                              BusinessDayConvention bdc, #= Following,
                              DayCounter& dc) except +
        # calculate the reference date based on the global evaluation date
        BlackVolTermStructure(Natural settlementDays,
                              Calendar& cal,
                              BusinessDayConvention bdc, #= Following,
                              DayCounter& dc) except +

        # spot volatility
        Volatility blackVol(Date& maturity,
                            Real strike,
                            bool extrapolate) #= false)
        # spot volatility
        Volatility blackVol(Time maturity,
                            Real strike,
                            bool extrapolate) #= false)
        # spot variance
        Real blackVariance(Date& maturity,
                           Real strike,
                           bool extrapolate) #= false)
        # spot variance
        Real blackVariance(Time maturity,
                           Real strike,
                           bool extrapolate) #= false)
        # forward (at-the-money) volatility
        Volatility blackForwardVol(Date& date1,
                                   Date& date2,
                                   Real strike,
                                   bool extrapolate) #= false)
        # forward (at-the-money) volatility
        Volatility blackForwardVol(Time time1,
                                   Time time2,
                                   Real strike,
                                   bool extrapolate) #= false)
        # forward (at-the-money) variance
        Real blackForwardVariance(Date& date1,
                                  Date& date2,
                                  Real strike,
                                  bool extrapolate) #= false)
        # forward (at-the-money) variance
        Real blackForwardVariance(Time time1,
                                  Time time2,
                                  Real strike,
                                  bool extrapolate) #= false)

    cdef cppclass BlackVolatilityTermStructure(BlackVolTermStructure):
        # See the TermStructure documentation for issues regarding
        # constructors
        # warning term structures initialized by means of this
        #   constructor must manage their own reference date
        #  by overriding the referenceDate() method.

        BlackVolatilityTermStructure(BusinessDayConvention bdc, #= Following,
                                     DayCounter& dc) except +
        # initialize with a fixed reference date
        BlackVolatilityTermStructure(Date& referenceDate,
                                     Calendar& cal, #= Calendar(),
                                     BusinessDayConvention bdc, #= Following,
                                     DayCounter& dc) except +
        # calculate the reference date based on the global evaluation date
        BlackVolatilityTermStructure(Natural settlementDays,
                                     Calendar& cal,
                                     BusinessDayConvention bdc, #= Following,
                                     DayCounter& dc) except +

    cdef cppclass BlackVarianceTermStructure(BlackVolTermStructure):
        # See the TermStructure documentation for issues regarding
        # constructors.
        #
        #   warning term structures initialized by means of this
        #                   constructor must manage their own reference date
        #                   by overriding the referenceDate() method.
        #
        BlackVarianceTermStructure(BusinessDayConvention bdc, # = Following,
                                   DayCounter& dc) except +
        # initialize with a fixed reference date
        BlackVarianceTermStructure(Date& referenceDate,
                                   Calendar& cal, #= Calendar(),
                                   BusinessDayConvention bdc, #= Following,
                                   DayCounter& dc) except +
        # calculate the reference date based on the global evaluation date
        BlackVarianceTermStructure(Natural settlementDays,
                                   Calendar&,
                                   BusinessDayConvention bdc, #= Following,
                                   DayCounter& dc) except +
