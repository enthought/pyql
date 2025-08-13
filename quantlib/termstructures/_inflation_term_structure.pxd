"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from libcpp cimport bool

from quantlib.ext cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period, Frequency
from quantlib.termstructures.inflation._seasonality cimport Seasonality
from .._termstructure cimport TermStructure

cdef extern from 'ql/termstructures/inflationtermstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass InflationTermStructure(TermStructure):
        Date baseDate()
        Real baseRate()

    cdef cppclass ZeroInflationTermStructure(InflationTermStructure):
        ZeroInflationTermStructure(Date baseDate,
                                   Frequency frequency,
                                   DayCounter& dayCounter,
                                   const shared_ptr[Seasonality]& seasonality # = shared_ptr<Seasonality>()
        ) except +
        ZeroInflationTermStructure(const Date& referenceDate,
                                   Date baseDate,
                                   Frequency frequency,
                                   const DayCounter& dayCounter,
                                   const shared_ptr[Seasonality] &seasonality # = shared_ptr<Seasonality>())
        ) except +
        ZeroInflationTermStructure(Natural settlementDays,
                                   const Calendar& calendar,
                                   Date baseDate,
                                   Frequency frequency,
                                   const DayCounter& dayCounter,
                                   const shared_ptr[Seasonality] &seasonality # = boost::shared_ptr<Seasonality>()
        ) except +

        Rate zeroRate(Date& d,
                      Period& inst_obs_lag,
                      bool force_linear_interpolation,
                      bool extrapolate)

        Rate zeroRate(Time t,
                      bool extrapolate)


    cdef cppclass YoYInflationTermStructure(InflationTermStructure):
        YoYInflationTermStructure(DayCounter& dayCounter,
                                  Rate baseYoYRate,
                                  Frequency frequency,
                                  const DayCounter& dayCounter,
                                  const shared_ptr[Seasonality]& seasonality) except +
        YoYInflationTermStructure(Date& referenceDate,
                                  Date baseDate,
                                  Rate baseYoYRate,
                                  Frequency frequency,
                                  const DayCounter& dayCounter,
                                  const shared_ptr[Seasonality]& seasonality) except +
        YoYInflationTermStructure(Natural settlmentDays,
                                  const Calendar& calendar,
                                  Date baseDate,
                                  Rate baseYoYRate,
                                  Frequency frequency,
                                  const DayCounter& dayCounter,
                                  const shared_ptr[Seasonality]& seasonality) except +

        Rate yoyRate(Date& d,
                      Period& inst_obs_lag,
                      bool force_linear_interpolation,
                      bool extrapolate) except +

        Rate yoyRate(Time t,
                      bool extrapolate) except +


        # TODO: add more methods and inspectors
