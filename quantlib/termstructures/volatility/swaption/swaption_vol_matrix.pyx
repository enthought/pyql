from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

from quantlib.time._period cimport Period as QlPeriod
from quantlib.time.date cimport Period
from quantlib.time.calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.time.daycounter cimport DayCounter
from quantlib.math.matrix cimport Matrix
from ..volatilitytype cimport VolatilityType
from ..volatilitytype cimport ShiftedLognormal
cimport _swaption_vol_structure as _svs

cdef class SwaptionVolatilityMatrix(SwaptionVolatilityDiscrete):

    def __init__(self, Calendar calendar not None,
                 BusinessDayConvention bdc,
                 list option_tenors not None,
                 list swap_tenors not None,
                 Matrix volatilities not None,
                 DayCounter day_counter not None,
                 bool flat_extrapolation=False,
                 VolatilityType vol_type=ShiftedLognormal,
                 Matrix shifts=Matrix.__new__(Matrix)):
        cdef vector[QlPeriod] option_tenors_vec
        cdef vector[QlPeriod] swap_tenors_vec

        for t in option_tenors:
            option_tenors_vec.push_back(deref((<Period?>t)._thisptr))

        for t in swap_tenors:
            swap_tenors_vec.push_back(deref((<Period?>t)._thisptr))

        self._thisptr = shared_ptr[_svs.SwaptionVolatilityStructure](
            new _svm.SwaptionVolatilityMatrix(
                deref(calendar._thisptr),
                bdc,
                option_tenors_vec,
                swap_tenors_vec,
                volatilities._thisptr,
                deref(day_counter._thisptr),
                flat_extrapolation,
                vol_type,
                shifts._thisptr
            )
        )
