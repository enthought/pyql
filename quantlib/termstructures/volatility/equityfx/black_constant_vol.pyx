from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr, Handle
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from .black_vol_term_structure cimport BlackVolatilityTermStructure
from quantlib.quotes cimport Quote
cimport quantlib._quote as _qt
from . cimport _black_vol_term_structure as _bvts
from . cimport _black_constant_vol as _bcv
from ..._vol_term_structure cimport VolatilityTermStructure


cdef class BlackConstantVol(BlackVolatilityTermStructure):
    """
    Constant Black volatility, no time-strike dependence

    This class implements the BlackVolatilityTermStructure
    interface for a constant Black volatility (no time/strike
    dependence)

    Attributes
    ----------
    reference_date : :obj:`Date`
    calendar : :obj:`Calendar`
    volatility : float or :obj:`Quote`
    day_counter: :obj:`DayCounter`

    """

    def __init__(self,
                 Date reference_date not None,
                 Calendar calendar not None,
                 volatility,
                 DayCounter daycounter not None):

        cdef Handle[_qt.Quote] volatility_handle
        if isinstance(volatility, Quote):
            volatility_handle = Handle[_qt.Quote]((<Quote>volatility)._thisptr)
            self._thisptr = shared_ptr[VolatilityTermStructure](
                new _bcv.BlackConstantVol(
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    volatility_handle,
                    deref(daycounter._thisptr)
                )
            )
        elif isinstance(volatility, float):
            self._thisptr = shared_ptr[VolatilityTermStructure](
                new _bcv.BlackConstantVol(
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    <double>volatility,
                    deref(daycounter._thisptr)
                )
            )
