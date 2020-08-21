include '../../../types.pxi'

from cython.operator cimport dereference as deref

from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr
from quantlib.math.matrix cimport Matrix
cimport quantlib.math.interpolation as intpl
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.time._date cimport Date as _Date
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._daycounter cimport DayCounter as _DayCounter

from .black_vol_term_structure cimport BlackVarianceTermStructure
from . cimport _black_variance_surface as _bvs
from . cimport _black_vol_term_structure as _bvts

cpdef public enum Extrapolation:
    ConstantExtrapolation = _bvs.ConstantExtrapolation
    InterpolatorDefaultExtrapolation = _bvs.InterpolatorDefaultExtrapolation

cdef inline _bvs.BlackVarianceSurface* get_bvs(BlackVarianceSurface bvs):
    """ Utility function to extract a properly casted BlackVarianceSurface out
    of the internal _thisptr attribute of the BlackVolTermStructure base class.
    """

    cdef _bvs.BlackVarianceSurface* ref = <_bvs.BlackVarianceSurface*>bvs._thisptr.get()
    return ref


cdef class BlackVarianceSurface(BlackVarianceTermStructure):
    """"
    Black volatility surface modelled as variance surface
    This class calculates time/strike dependent Black volatilities
    using as input a matrix of Black volatilities observed in the
    market.

    The calculation is performed interpolating on the variance surface.
    Bilinear interpolation is used as default; this can be changed by the
    setInterpolation() method.

    todo check time extrapolation

    Attributes
    ----------
    reference_date : Date
    cal : Calendar
    dates : list of `obj`:Date
    strikes : list of floats
    black_vol_matrix : Matrix
    dc : DayCounter
    lower_extrap : Extrapolation
    upper_extrap : Extrapolation

    """

    def __init__(self,
                 Date reference_date,
                 Calendar cal,
                 list dates,
                 vector[Real] strikes,
                 Matrix black_vol_matrix,
                 DayCounter dc,
                 Extrapolation lower_extrap = Extrapolation.InterpolatorDefaultExtrapolation,
                 Extrapolation upper_extrap = Extrapolation.InterpolatorDefaultExtrapolation,
                 ):

        cdef vector[_Date] _dates
        for d in dates:
            _dates.push_back(deref((<Date>d)._thisptr))

        self._thisptr = shared_ptr[_bvts.BlackVolTermStructure](
                                new _bvs.BlackVarianceSurface(
                                             deref(reference_date._thisptr),
                                             deref(cal._thisptr),
                                             _dates,
                                             strikes,
                                             (<Matrix>black_vol_matrix)._thisptr,
                                             deref(dc._thisptr),
                                             lower_extrap,
                                             upper_extrap,
                                             ))


    # TermStructure interface
    @property
    def day_counter(self):
        """ ql lacks a copy constructor for DayCounter"""
        cdef _DayCounter _dc = get_bvs(self).dayCounter()
        cdef DayCounter dc = DayCounter.from_name(_dc.name())
        return dc

    @property
    def max_date(self):
        return date_from_qldate(get_bvs(self).maxDate())

    @property
    def min_strike(self):
        return get_bvs(self).minStrike()

    @property
    def max_strike(self):
        return get_bvs(self).maxStrike()

    # Modifiers
    def set_interpolation(self, Interpolator i):
        if i == Bilinear:
            get_bvs(self).setInterpolation[intpl.Bilinear]() # Calls the default constructor
        elif i == Bicubic:
            get_bvs(self).setInterpolation[intpl.Bicubic]()
        else:
            raise ValueError("Interpolator must be Bilinear or Bicubic")
