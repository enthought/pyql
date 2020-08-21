include '../../../types.pxi'
from cython.operator cimport dereference as deref

from libcpp cimport bool

from quantlib.time.date cimport Date
from quantlib.time._date cimport Date as _Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._daycounter cimport DayCounter as _DayCounter
from quantlib.time.calendar cimport Calendar
from quantlib.time._calendar cimport Calendar as _Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention, Following


cdef class BlackVolTermStructure:
    """ Black-volatility term structure

        This abstract class defines the interface of concrete
        Black-volatility term structures which will be derived from
        this one.

        Volatilities are assumed to be expressed on an annual basis.
    """

    def __init__(self):
        raise NotImplementedError

    def blackVol(self, maturity, Real strike, bool extrapolate=False):
        """ spot volatility
        """
        if isinstance(maturity, float):
            return self._thisptr.get().blackVol(<float>maturity, strike, extrapolate)
        elif isinstance(maturity, Date):
            return self._thisptr.get().blackVol(
                deref((<Date>maturity)._thisptr),
                strike,
                extrapolate
            )
        else:
            raise TypeError("maturity must be either Date or Time")

    def blackVariance(self, maturity, Real strike, bool extrapolate=False):
        """ spot variance
        """
        if isinstance(maturity, float):
            return self._thisptr.get().blackVariance(
                <float>maturity,
                strike,
                extrapolate
            )
        elif isinstance(maturity, Date):
            return self._thisptr.get().blackVariance(
                deref((<Date>maturity)._thisptr),
                strike,
                extrapolate
            )
        else:
            raise TypeError("maturity must be either Date or Time")

    def blackForwardVol(self, time_1, time_2, Real strike, bool extrapolate=False):
        """ forward (at-the-money) volatility
        """
        if isinstance(time_1, float) and isinstance(time_2, float):
            return self._thisptr.get().blackForwardVol(
                <float>time_1,
                <float>time_2,
                strike,
                extrapolate
            )
        elif isinstance(time_1, Date) and isinstance(time_2, Date):
            return self._thisptr.get().blackForwardVol(
                deref((<Date>time_1)._thisptr),
                deref((<Date>time_2)._thisptr),
                strike,
                extrapolate
            )
        else:
            raise TypeError("times must be either Date or Time")

    def blackForwardVariance(self, time_1, time_2, Real strike, bool extrapolate=False):
        """  forward (at-the-money) variance
        """
        if isinstance(time_1, float) and isinstance(time_2, float):
            return self._thisptr.get().blackForwardVariance(
                <float>time_1,
                <float>time_2,
                strike,
                extrapolate
            )
        elif isinstance(time_1, Date) and isinstance(time_2, Date):
            return self._thisptr.get().blackForwardVariance(
                deref((<Date>time_1)._thisptr),
                deref((<Date>time_2)._thisptr),
                strike,
                extrapolate
            )
        else:
            raise TypeError("times must be either Date or Time")


cdef class BlackVolatilityTermStructure(BlackVolTermStructure):
    def __init__(self):
        raise NotImplementedError


cdef class BlackVarianceTermStructure(BlackVolTermStructure):
    def __init__(self):
        raise NotImplementedError
