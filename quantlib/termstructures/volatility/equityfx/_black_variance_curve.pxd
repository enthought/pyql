include '../../../types.pxi'
from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from ._black_vol_term_structure cimport BlackVarianceTermStructure


"""
Black volatility curve modelled as variance curve
This class calculates time-dependent Black volatilities using
as input a vector of (ATM) Black volatilities observed in the
market.

The calculation is performed interpolating on the variance curve.
Linear interpolation is used as default; this can be changed
by the setInterpolation() method.

For strike dependence, see BlackVarianceSurface.

TODO: check time extrapolation
"""

cdef extern from 'ql/termstructures/volatility/equityfx/blackvariancecurve.hpp' namespace 'QuantLib':

    cdef cppclass BlackVarianceCurve(BlackVarianceTermStructure):

        BlackVarianceCurve(Date& referenceDate,
                           vector[Date]& dates,
                           vector[Volatility]& blackVolCurve,
                           DayCounter& dayCounter,
                           bool forceMonotoneVariance) except +
        # TermStructure interface
        DayCounter dayCounter()
        Date maxDate()

        #  VolatilityTermStructure interface
        Real minStrike()
        Real maxStrike()
        
