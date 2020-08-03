include '../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr, Handle
from quantlib.time._date cimport Date, Period
from quantlib.time._period cimport Frequency
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.inflation._interpolated_zero_inflation_curve cimport \
    InterpolatedZeroInflationCurve
from quantlib.termstructures.inflation.inflation_traits cimport ZeroInflationTraits

cdef extern from 'ql/termstructures/inflation/piecewisezeroinflationcurve.hpp' namespace 'QuantLib':
    cdef cppclass PiecewiseZeroInflationCurve[T](InterpolatedZeroInflationCurve[T]):
        PiecewiseZeroInflationCurve(const Date& referenceDate,
                                    const Calendar& calendar,
                                    const DayCounter& dayCounter,
                                    const Period& lag,
                                    Frequency frequency,
                                    bool index_is_interpolated,
                                    Rate baseZeroRate,
                                    const vector[shared_ptr[ZeroInflationTraits.helper]]& instruments,
                                    Real accuracy) #= 1.0e-12,
