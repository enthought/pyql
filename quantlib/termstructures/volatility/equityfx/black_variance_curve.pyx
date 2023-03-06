include '../../../types.pxi'
from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time._date cimport Date as _Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._daycounter cimport DayCounter as QlDayCounter

from .black_vol_term_structure cimport BlackVarianceTermStructure
from . cimport _black_vol_term_structure as _bvts

from ..._vol_term_structure cimport VolatilityTermStructure


cdef class BlackVarianceCurve(BlackVarianceTermStructure):
    """ Black volatility curve modelled as variance curve

    This class calculates time-dependent Black volatilities using
    as input a vector of (ATM) Black volatilities observed in the
    market.

    The calculation is performed interpolating on the variance curve.
    Linear interpolation is used as default; this can be changed
    by the set_interpolation() method.

    For strike dependence, see BlackVarianceSurface.


    Parameters
    ----------
    reference_date : Date
    dates : list of Date
    black_vols : list of Volatility
    day_counter: DayCounter
    force_monotone_variance: bool

    """
    cdef inline _bvc.BlackVarianceCurve* get_bvc(self):
        """ Utility function to extract a properly casted BlackVarianceCurve out
        of the internal _thisptr attribute of the BlackVolTermStructure base class.
        """
        return <_bvc.BlackVarianceCurve*>self.as_ptr()

    def __init__(self,
                 Date reference_date,
                 list dates,
                 vector[Volatility] black_vols,
                 DayCounter day_counter,
                 bool force_monotone_variance = True,
                 ):

        cdef vector[_Date] _dates
        for d in dates:
            _dates.push_back(deref((<Date?>d)._thisptr))

        self._thisptr.reset(
            new _bvc.BlackVarianceCurve(
                deref(reference_date._thisptr),
                _dates,
                black_vols,
                deref(day_counter._thisptr),
                force_monotone_variance,
            )
        )

    @property
    def min_strike(self):
        return self.get_bvc().minStrike()

    @property
    def max_strike(self):
       return self.get_bvc().maxStrike()
