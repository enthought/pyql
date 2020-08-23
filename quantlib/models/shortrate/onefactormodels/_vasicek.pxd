"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from libcpp.vector cimport vector
from quantlib.handle cimport Handle, shared_ptr

from quantlib.instruments._option cimport Type as OptionType
from quantlib.math._optimization cimport OptimizationMethod, EndCriteria
from quantlib.models._calibration_helper cimport BlackCalibrationHelper
from quantlib.models.shortrate._onefactor_model cimport OneFactorAffineModel

cdef extern from 'ql/models/shortrate/onefactormodels/vasicek.hpp' namespace 'QuantLib':

    cdef cppclass Vasicek(OneFactorAffineModel):

        Vasicek() # fake empty constructor due to Cython issue

        Vasicek(Rate r0, Real a, Real b, Real sigma, Real Lambda) except +

        Real a() except +

        Real b() except +

        Real Lambda 'lambda'() except +

        Real sigma() except +
