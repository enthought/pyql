"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
cimport _hullwhite as _hw
cimport _vasicek as _va

from quantlib.handle cimport Handle, shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib._quote as _qt
cimport quantlib.models._calibration_helper as _ch
cimport quantlib.models._model as _mo

from quantlib.models.shortrate.calibrationhelpers.swaption_helper cimport SwaptionHelper
from quantlib.models.calibration_helper cimport CalibrationHelper

from quantlib.quotes cimport Quote, SimpleQuote
from quantlib.termstructures.yields.flat_forward cimport YieldTermStructure
from quantlib.math.optimization cimport OptimizationMethod, EndCriteria

from vasicek cimport Vasicek

cdef class HullWhite(Vasicek):
    """ Single-factor Hull-White (extended Vasicek) model.
    The standard single-factor Hull-White model is defined by
    .. math::
    dr_t = (\theta(t) - \alpha r_t)dt + \sigma dW_t

    where \alpha and \sigma are constants.

    """

    def __cinit__(self):
        pass

    def __dealloc(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __init__(self,
       YieldTermStructure term_structure=YieldTermStructure(),
       Real a=0,
       Real sigma=0):

        self._thisptr = new shared_ptr[_mo.CalibratedModel](
            new _hw.HullWhite(
                term_structure._thisptr,
                a, sigma
	    )
	)

    def __str__(self):
        return 'Hull-White model\na (speed of mean revertion): %f sigma: %f' % \
          (self.a, self.sigma)


    property a:
        def __get__(self):
            return (<_hw.HullWhite*> self._thisptr.get()).a()

    property sigma:
        def __get__(self):
            return (<_hw.HullWhite*> self._thisptr.get()).sigma()

    def calibrate(self, list helpers, OptimizationMethod method, EndCriteria
            end_criteria):

        #convert list to vector
        cdef vector[shared_ptr[_ch.CalibrationHelper]] helpers_vector

        cdef shared_ptr[_ch.CalibrationHelper] chelper
        for helper in helpers:
            chelper = deref((<CalibrationHelper>helper)._thisptr)
            helpers_vector.push_back(chelper)

        (<_hw.HullWhite*> self._thisptr.get()).calibrate(
            helpers_vector,
            deref(method._thisptr.get()),
            deref(end_criteria._thisptr.get())
        )
