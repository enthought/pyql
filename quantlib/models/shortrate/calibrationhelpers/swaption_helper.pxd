"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.handle cimport shared_ptr
from quantlib.models.calibration_helper cimport BlackCalibrationHelper

cdef class SwaptionHelper(BlackCalibrationHelper):
    pass
