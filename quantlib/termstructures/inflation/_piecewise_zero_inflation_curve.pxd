from quantlib.types cimport Real
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._period cimport Frequency
from quantlib.time._daycounter cimport DayCounter
from ._interpolated_zero_inflation_curve cimport InterpolatedZeroInflationCurve
from ._seasonality cimport Seasonality
from .inflation_traits cimport ZeroInflationTraits

cdef extern from 'ql/termstructures/inflation/piecewisezeroinflationcurve.hpp' namespace 'QuantLib' nogil:
    cdef cppclass PiecewiseZeroInflationCurve[T](InterpolatedZeroInflationCurve[T]):
        PiecewiseZeroInflationCurve(const Date& referenceDate,
                                    Date baseDate,
                                    Frequency frequency,
                                    const DayCounter& dayCounter,
                                    const vector[shared_ptr[ZeroInflationTraits.helper]]& instruments,
                                    shared_ptr[Seasonality] seasonality,
                                    Real accuracy) #= 1.0e-12,
