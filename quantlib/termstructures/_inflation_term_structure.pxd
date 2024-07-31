"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from libcpp cimport bool

from quantlib.handle cimport shared_ptr, Handle
from quantlib.time._date cimport Date
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._period cimport Period, Frequency
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.inflation._seasonality cimport Seasonality


cdef extern from 'ql/termstructures/inflationtermstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass InflationTermStructure:

        InflationTermStructure() except +
        Date& referenceDate()
        Date& maxDate()
        Date& baseDate()
        Period observationLag()
        Rate baseRate()


    cdef cppclass ZeroInflationTermStructure(InflationTermStructure):

        ZeroInflationTermStructure() except +
        ZeroInflationTermStructure(DayCounter& dayCounter,
                                   Rate baseZeroRate,
                                   Period& lag,
                                   Frequency frequency,
                                   const Handle[YieldTermStructure]& yTS,
                                   const shared_ptr[Seasonality]& seasonality # = shared_ptr<Seasonality>()
        ) except +
        ZeroInflationTermStructure(const Date& referenceDate,
                                   const Calendar& calendar,
                                   const DayCounter& dayCounter,
                                   Rate baseZeroRate,
                                   const Period& lag,
                                   Frequency frequency,
                                   const Handle[YieldTermStructure]& yTS,
                                   const shared_ptr[Seasonality] &seasonality # = shared_ptr<Seasonality>())
        ) except +
        ZeroInflationTermStructure(Natural settlementDays,
                                   const Calendar& calendar,
                                   const DayCounter& dayCounter,
                                   Rate baseZeroRate,
                                   const Period& lag,
                                   Frequency frequency,
                                   const Handle[YieldTermStructure]& yTS,
                                   const shared_ptr[Seasonality] &seasonality # = boost::shared_ptr<Seasonality>()
        ) except +

        Rate zeroRate(Date& d,
                      Period& inst_obs_lag,
                      bool force_linear_interpolation,
                      bool extrapolate)

        Rate zeroRate(Time t,
                      bool extrapolate)


    cdef cppclass YoYInflationTermStructure(InflationTermStructure):

        YoYInflationTermStructure() except +

        YoYInflationTermStructure(DayCounter& dayCounter,
                                  Rate baseZeroRate,
                                  Period& lag,
                                  Frequency frequency,
                                  bool indexIsInterpolated,
                                  const Handle[YieldTermStructure]& yTS,
                                  const shared_ptr[Seasonality]& seasonality) except +

        Rate yoyRate(Date& d,
                      Period& inst_obs_lag,
                      bool force_linear_interpolation,
                      bool extrapolate) except +

        Rate yoyRate(Time t,
                      bool extrapolate) except +


        # TODO: add more methods and inspectors
