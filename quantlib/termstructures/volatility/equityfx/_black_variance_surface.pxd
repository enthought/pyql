include '../../../types.pxi'

from libcpp.vector cimport vector

from quantlib.time._date cimport Date
from quantlib.time._calendar cimport Calendar
from quantlib.time._daycounter cimport DayCounter
from quantlib.math._matrix cimport Matrix
from ._black_vol_term_structure cimport BlackVarianceTermStructure


cdef extern from 'ql/termstructures/volatility/equityfx/blackvariancesurface.hpp' namespace 'QuantLib::BlackVarianceSurface':

    cdef enum Extrapolation:
        ConstantExtrapolation
        InterpolatorDefaultExtrapolation

cdef extern from 'ql/termstructures/volatility/equityfx/blackvariancesurface.hpp' namespace 'QuantLib':

    cdef cppclass BlackVarianceSurface(BlackVarianceTermStructure):

        BlackVarianceSurface(Date& referenceDate,
                             Calendar& cal,
                             vector[Date]& dates,
                             vector[Real]& strikes,
                             Matrix& blackVolMatrix,
                             DayCounter& dayCounter,
                             Extrapolation lowerExtrapolation,
                             Extrapolation upperExtrapolation,
                             ) except +

        DayCounter dayCounter()
        Date maxDate()

        # VolatilityTermStructure interface
        Real minStrike()
        Real maxStrike()
        #
        # Modifiers
        void setInterpolation[Interpolator](Interpolator& i) # = Interpolator()
