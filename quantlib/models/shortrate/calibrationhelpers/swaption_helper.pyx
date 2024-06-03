"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.types cimport Real
from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
from cython.operator cimport dereference as deref

from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.termstructures.volatility.volatilitytype cimport VolatilityType
from quantlib.time.daycounter cimport DayCounter
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.instruments.fixedvsfloatingswap cimport FixedVsFloatingSwap
from quantlib.instruments.swaption cimport Swaption
from quantlib.time.date cimport Period, Date
from quantlib.quote cimport Quote
from quantlib.models.calibration_helper import RelativePriceError
from quantlib.utilities.null cimport Null

cimport quantlib._quote as _qt
cimport quantlib.termstructures._yield_term_structure as _yts
cimport quantlib.indexes._ibor_index as _ii
cimport quantlib.models._calibration_helper as _ch
from . cimport _swaption_helper as _sh

from quantlib.models.calibration_helper cimport BlackCalibrationHelper, CalibrationErrorType


cdef class SwaptionHelper(BlackCalibrationHelper):

    def __init__(self,
                 maturity_or_exercise_date not None,
                 length_or_end_date not None,
                 Quote volatility not None,
                 IborIndex index not None,
                 Period fixed_leg_tenor not None,
                 DayCounter fixed_leg_daycounter not None,
                 DayCounter floating_leg_daycounter not None,
                 HandleYieldTermStructure ts not None,
                 CalibrationErrorType error_type=RelativePriceError,
                 Real strike=Null[Real](),
                 Real nominal=1.0,
                 VolatilityType vol_type=VolatilityType.ShiftedLognormal,
                 Real shift=0.0):

        if isinstance(maturity_or_exercise_date, Period) and isinstance(length_or_end_date, Period):
            self._thisptr.reset(
                new _sh.SwaptionHelper(
                    deref((<Period>maturity_or_exercise_date)._thisptr),
                    deref((<Period>length_or_end_date)._thisptr),
                    volatility.handle(),
                    static_pointer_cast[_ii.IborIndex](index._thisptr),
                    deref(fixed_leg_tenor._thisptr),
                    deref(fixed_leg_daycounter._thisptr),
                    deref(floating_leg_daycounter._thisptr),
                    ts.handle,
                    error_type,
                    strike,
                    nominal,
                    vol_type,
                    shift
                )
            )
        elif isinstance(maturity_or_exercise_date, Date) and isinstance(length_or_end_date, Period):
            self._thisptr.reset(
                _sh.SwaptionHelper_(
                    (<Date>maturity_or_exercise_date)._thisptr,
                    deref((<Period>length_or_end_date)._thisptr),
                    volatility.handle(),
                    static_pointer_cast[_ii.IborIndex](index._thisptr),
                    deref(fixed_leg_tenor._thisptr),
                    deref(fixed_leg_daycounter._thisptr),
                    deref(floating_leg_daycounter._thisptr),
                    ts.handle,
                    error_type,
                    strike,
                    nominal,
                    vol_type,
                    shift
                )
            )
        elif isinstance(maturity_or_exercise_date, Date) and isinstance(length_or_end_date, Date):
            self._thisptr.reset(
                _sh.SwaptionHelper2_(
                    (<Date>maturity_or_exercise_date)._thisptr,
                    (<Date>length_or_end_date)._thisptr,
                    volatility.handle(),
                    static_pointer_cast[_ii.IborIndex](index._thisptr),
                    deref(fixed_leg_tenor._thisptr),
                    deref(fixed_leg_daycounter._thisptr),
                    deref(floating_leg_daycounter._thisptr),
                    ts.handle,
                    error_type,
                    strike,
                    nominal,
                    vol_type,
                    shift
                )
            )

    def underlying_swap(self):
        cdef FixedVsFloatingSwap swap = FixedVsFloatingSwap.__new__(FixedVsFloatingSwap)
        swap._thisptr = (<_sh.SwaptionHelper*>self._thisptr.get()).underlyingSwap()
        return  swap

    def underlying_swaption(self):
        cdef Swaption swaption = Swaption.__new__(Swaption)
        swaption._thisptr = (<_sh.SwaptionHelper*>self._thisptr.get()).swaption()
        return swaption
