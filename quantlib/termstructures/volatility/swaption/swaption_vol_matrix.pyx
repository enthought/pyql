include '../../../types.pxi'
from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, Handle

from quantlib._quote cimport Quote as QlQuote
from quantlib.quote cimport Quote
from quantlib.time._period cimport Period as QlPeriod
from quantlib.time.date cimport Period, Date
from quantlib.time.calendar cimport Calendar
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.time.daycounter cimport DayCounter
from quantlib.math.matrix cimport Matrix
from ..volatilitytype cimport VolatilityType, ShiftedLognormal
cimport quantlib.termstructures.volatility._volatilitytype as _voltype
from ..._vol_term_structure cimport VolatilityTermStructure

cdef build_vols_shifts(list volatilities, list shifts,
                       vector[vector[Handle[QlQuote]]]& c_vols,
                       vector[vector[Real]]& c_shifts):
    cdef vector[Handle[QlQuote]] row
    cdef vector[Real] row2
    cdef Quote q
    cdef Real r
    for v, s in zip(volatilities, shifts):
        row.clear()
        row2.clear()
        for q, r in zip(v, s):
            row.push_back(q.handle())
            row2.push_back(<Real>r)
        c_vols.push_back(row)
        c_shifts.push_back(row2)

cdef class SwaptionVolatilityMatrix(SwaptionVolatilityDiscrete):

    def __init__(self, Calendar calendar not None,
                 BusinessDayConvention bdc,
                 list option_tenors not None,
                 list swap_tenors not None,
                 Matrix volatilities not None,
                 DayCounter day_counter not None,
                 bool flat_extrapolation=False,
                 VolatilityType vol_type=ShiftedLognormal,
                 shifts=[]):
        cdef vector[QlPeriod] option_tenors_vec
        cdef vector[QlPeriod] swap_tenors_vec
        cdef vector[vector[Handle[QlQuote]]] c_vols
        cdef vector[vector[Real]] c_shifts


        for t in option_tenors:
            option_tenors_vec.push_back(deref((<Period?>t)._thisptr))

        for t in swap_tenors:
            swap_tenors_vec.push_back(deref((<Period?>t)._thisptr))

        if shifts == [] and isinstance(volatilities, Matrix):
            shifts = Matrix.__new__(Matrix)
        if isinstance(volatilities, Matrix) and isinstance(shifts, Matrix):
            self._thisptr = shared_ptr[VolatilityTermStructure](
                new _svm.SwaptionVolatilityMatrix(
                    deref(calendar._thisptr),
                    bdc,
                    option_tenors_vec,
                    swap_tenors_vec,
                    (<Matrix>volatilities)._thisptr,
                    deref(day_counter._thisptr),
                    flat_extrapolation,
                    <_voltype.VolatilityType>vol_type,
                    (<Matrix>shifts)._thisptr
                )
            )
        elif isinstance(volatilities, list) and isinstance(shifts, list):
            build_vols_shifts(volatilities, shifts, c_vols, c_shifts)

            self._thisptr = shared_ptr[VolatilityTermStructure](
                _svm.SwaptionVolatilityMatrix_(
                    deref(calendar._thisptr),
                    bdc,
                    option_tenors_vec,
                    swap_tenors_vec,
                    c_vols,
                    deref(day_counter._thisptr),
                    flat_extrapolation,
                    vol_type,
                    c_shifts
                )
            )
        else:
            raise TypeError("volatilities and shifts need to be both either Matrices, "
                            "or lists of lists")

    @classmethod
    def from_reference_date(cls, Date reference_date not None,
                            Calendar calendar not None,
                            BusinessDayConvention bdc,
                            option_tenors,
                            swap_tenors,
                            volatilities,
                            DayCounter day_counter not None,
                            bool flat_extrapolation=False,
                            VolatilityType vol_type=ShiftedLognormal,
                            shifts=[]):
        cdef SwaptionVolatilityMatrix instance = cls.__new__(cls)
        cdef vector[QlPeriod] option_tenors_vec
        cdef vector[QlPeriod] swap_tenors_vec
        cdef vector[vector[Handle[QlQuote]]] c_vols
        cdef vector[vector[Real]] c_shifts

        for t in option_tenors:
            option_tenors_vec.push_back(deref((<Period?>t)._thisptr))

        for t in swap_tenors:
            swap_tenors_vec.push_back(deref((<Period?>t)._thisptr))

        if shifts == [] and isinstance(volatilities, Matrix):
            shifts = Matrix.__new__(Matrix)

        if isinstance(volatilities, Matrix) and isinstance(shifts, Matrix):
            instance._thisptr = shared_ptr[VolatilityTermStructure](
                new _svm.SwaptionVolatilityMatrix(
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    bdc,
                    option_tenors_vec,
                    swap_tenors_vec,
                    (<Matrix>volatilities)._thisptr,
                    deref(day_counter._thisptr),
                    flat_extrapolation,
                    vol_type,
                    (<Matrix>shifts)._thisptr
                )
            )
        elif isinstance(volatilities, list) and isinstance(shifts, list):
            build_vols_shifts(volatilities, shifts, c_vols, c_shifts)
            instance._thisptr = shared_ptr[VolatilityTermStructure](
                _svm.SwaptionVolatilityMatrix__(
                    deref(reference_date._thisptr),
                    deref(calendar._thisptr),
                    bdc,
                    option_tenors_vec,
                    swap_tenors_vec,
                    c_vols,
                    deref(day_counter._thisptr),
                    flat_extrapolation,
                    vol_type,
                    c_shifts
                )
            )
        else:
            raise TypeError("volatilities and shifts need to be both either Matrices, "
                            "or lists of lists")
        return instance
