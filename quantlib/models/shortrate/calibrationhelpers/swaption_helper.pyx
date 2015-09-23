"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from cython.operator cimport dereference as deref

from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
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
                 Period maturity,
                 Period length,
                 Quote volatility,
                 IborIndex index,
                 Period fixed_leg_tenor,
                 DayCounter fixed_leg_daycounter,
                 DayCounter floating_leg_daycounter,
                 YieldTermStructure ts,
                 error_type=RelativePriceError,
                 strike=None,
                 Real nominal=1.0):


        cdef QlDayCounter* _fixed_leg_daycounter = <QlDayCounter*>fixed_leg_daycounter._thisptr
        cdef QlDayCounter* _floating_leg_daycounter = <QlDayCounter*>floating_leg_daycounter._thisptr

        cdef Handle[_qt.Quote] volatility_handle = \
                Handle[_qt.Quote](deref(volatility._thisptr))

        cdef Handle[_yts.YieldTermStructure] yts_handle = \
            deref(ts._thisptr.get())

        if strike is None:
            strike = QL_NULL_REAL
            
        self._thisptr = new shared_ptr[_ch.CalibrationHelper](
            new _sh.SwaptionHelper(
                deref(maturity._thisptr.get()),
                deref(length._thisptr.get()),
                volatility_handle,
                deref(<shared_ptr[_ii.IborIndex]*> index._thisptr),
                deref(fixed_leg_tenor._thisptr.get()),
                deref(_fixed_leg_daycounter),
                deref(_floating_leg_daycounter),
                yts_handle,
                <_ch.CalibrationErrorType>error_type,
                strike,
                nominal))
