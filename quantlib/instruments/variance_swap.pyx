from quantlib.types cimport Real
from quantlib.handle cimport shared_ptr
from .._instrument cimport Instrument as _Instrument
from quantlib.time.date cimport (Date, _pydate_from_qldate, _qldate_from_pydate)
from libcpp cimport bool
from ._variance_swap cimport (VarianceSwap as _VarianceSwap, Type as _Type)
import datetime

cpdef public enum SwapType:
    Long = _Type.Long
    Short = _Type.Short

cdef inline _VarianceSwap* get_varianceswap(VarianceSwap swap):
    """
    Utility function to extract a properly casted Swap pointer out of the
    internal _thisptr attribute of the Instrument base class.
    """
    cdef _VarianceSwap* ref = <_VarianceSwap*>swap._thisptr.get()
    return ref

cdef class VarianceSwap(Instrument):
    """ Variance swap
        warning This class does not manage seasoned variance swaps.
        ingroup instruments

        Attributes
        ----------
        position : SwapType
        strik : Real
        notional : Real
        start_date : Date
        maturity_date : Date


    """
    def __init__(self,
                 SwapType position,
                 Real strike,
                 Real notional,
                 Date start_date,
                 Date maturity_date):

        self._thisptr = shared_ptr[_Instrument](new _VarianceSwap(<_Type>position,
                                                                  strike,
                                                                  notional,
                                                                  start_date._thisptr,
                                                                  maturity_date._thisptr,
                                                                  ))

    @property
    def strike(self):
        return get_varianceswap(self).strike()

    @property
    def position(self):
        return SwapType(get_varianceswap(self).position())

    @property
    def start_date(self):
        return _pydate_from_qldate(get_varianceswap(self).startDate())

    @property
    def maturity_date(self):
        return _pydate_from_qldate(get_varianceswap(self).maturityDate())

    @property
    def notional(self):
        return get_varianceswap(self).notional()

    @property
    def variance(self):
        return get_varianceswap(self).variance()
