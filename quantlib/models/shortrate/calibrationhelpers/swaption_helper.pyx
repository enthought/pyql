"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
from cython.operator cimport dereference as deref

from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.time.date cimport Period
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.quotes cimport Quote
from quantlib.models.calibration_helper import RelativePriceError
cimport quantlib._quote as _qt
cimport quantlib.termstructures._yield_term_structure as _yts
cimport quantlib.indexes._ibor_index as _ii
cimport quantlib.models._calibration_helper as _ch
cimport _swaption_helper as _sh

from quantlib.models.calibration_helper cimport CalibrationHelper

from quantlib.defines cimport QL_NULL_REAL

cdef class SwaptionHelper(CalibrationHelper):

    def __init__(self,
                 Period maturity not None,
                 Period length not None,
                 Quote volatility not None,
                 IborIndex index not None,
                 Period fixed_leg_tenor not None,
                 DayCounter fixed_leg_daycounter not None,
                 DayCounter floating_leg_daycounter not None,
                 YieldTermStructure ts not None,
                 error_type=RelativePriceError,
                 Real strike=QL_NULL_REAL,
                 Real nominal=1.0):

        cdef Handle[_qt.Quote] volatility_handle = \
                Handle[_qt.Quote](volatility._thisptr)

        self._thisptr = shared_ptr[_ch.CalibrationHelper](
            new _sh.SwaptionHelper(
                deref(maturity._thisptr),
                deref(length._thisptr),
                volatility_handle,
                static_pointer_cast[_ii.IborIndex](index._thisptr),
                deref(fixed_leg_tenor._thisptr),
                deref(fixed_leg_daycounter._thisptr),
                deref(floating_leg_daycounter._thisptr),
                ts._thisptr,
                <_ch.CalibrationErrorType>error_type,
                strike,
                nominal))

