"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._daycounter cimport DayCounter
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time._period cimport Period
from quantlib.models._calibration_helper cimport CalibrationHelper, CalibrationErrorType
cimport quantlib._quote as _qt

cdef extern from 'ql/models/shortrate/calibrationhelpers/swaptionhelper.hpp' namespace 'QuantLib':

    cdef cppclass SwaptionHelper(CalibrationHelper):

        SwaptionHelper(Period& maturity,
                       Period& length,
                       Handle[_qt.Quote]& volatility,
                       shared_ptr[IborIndex]& index,
                       Period& fixedLegTenor,
                       DayCounter& fixedLegDayCounter,
                       DayCounter& floatingLegDayCounter,
                       Handle[YieldTermStructure]& termStructure,
                       CalibrationErrorType errorType,
                       Real strike,
                       Real nominal) except +

