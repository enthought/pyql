"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from . cimport _calibration_helper as _ch
from quantlib.handle cimport shared_ptr

cpdef enum CalibrationErrorType:
    RelativePriceError = _ch.RelativePriceError
    PriceError = _ch.PriceError
    ImpliedVolError = _ch.ImpliedVolError

cdef class BlackCalibrationHelper:
    cdef shared_ptr[_ch.CalibrationHelper] _thisptr
    cdef inline _ch.BlackCalibrationHelper* as_ptr(self)
