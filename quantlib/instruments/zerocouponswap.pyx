from quantlib.types cimport Real, Natural
from quantlib.handle cimport static_pointer_cast
from quantlib.time.date cimport Date
from quantlib.time.calendar cimport Calendar
from quantlib.time.businessdayconvention cimport BusinessDayConvention, Following
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes cimport _ibor_index as _ib
from . cimport _zerocouponswap as _zcs

cdef class ZeroCouponSwap(Swap):
    def __init__(self, Type type, Real nominal, Date start_date, Date maturity, Real fixed_payment, IborIndex ibor_index, Calendar payment_calendar, BusinessDayConvention payment_convention=Following, Natural payment_delay=0):
        self._thisptr.reset(
            new _zcs.ZeroCouponSwap(
                type,
                nominal,
                start_date._thisptr,
                maturity._thisptr,
                fixed_payment,
                static_pointer_cast[_ib.IborIndex](ibor_index._thisptr),
                payment_calendar._thisptr,
                payment_convention,
                payment_delay
            )
        )
