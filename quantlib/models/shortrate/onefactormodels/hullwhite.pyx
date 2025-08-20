# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

""" Hull & White (HW) model"""
from quantlib.types cimport Real, Time
from libcpp.vector cimport vector
from libcpp cimport bool
from cython.operator cimport dereference as deref
from . cimport _hullwhite as _hw
from . cimport _vasicek as _va

from quantlib.handle cimport shared_ptr
cimport quantlib.termstructures.yields._flat_forward as _ff
cimport quantlib.models._calibration_helper as _ch
cimport quantlib.models._model as _mo

from quantlib.math.optimization cimport Constraint
from quantlib.models.shortrate.calibrationhelpers.swaption_helper cimport SwaptionHelper
from quantlib.models.calibration_helper cimport BlackCalibrationHelper

from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.math.optimization cimport OptimizationMethod, EndCriteria

from .vasicek cimport Vasicek

cdef class HullWhite(Vasicek):
    r""" Single-factor Hull-White (extended Vasicek) model.

     The standard single-factor Hull-White model is defined by

     .. math::
       dr_t = (\theta(t) - \alpha r_t)dt + \sigma dW_t

     where :math:`\alpha` and :math:`\sigma` are constants.

     .. warning::
        When the term structure is relinked the :math:`r_0` parameter
        of the underlying Vasicek model is not updated.

     """

    def __init__(self, HandleYieldTermStructure term_structure, Real a=0.1, Real sigma=0.01):

        self._thisptr = shared_ptr[_mo.CalibratedModel](
            new _hw.HullWhite(
                term_structure.handle,
                a, sigma
	    )
	)

    def __str__(self):
        return 'Hull-White model\na (speed of mean revertion): %f sigma: %f' % \
          (self.a, self.sigma)


    def calibrate(self, list helpers, OptimizationMethod method, EndCriteria
                  end_criteria, Constraint constraint=Constraint(),
                  vector[Real] weights=[], vector[bool] fix_parameters=[]):

        #convert list to vector
        cdef vector[shared_ptr[_ch.CalibrationHelper]] helpers_vector

        cdef shared_ptr[_ch.CalibrationHelper] chelper
        for helper in helpers:
            chelper = (<BlackCalibrationHelper>helper)._thisptr
            helpers_vector.push_back(chelper)

        (<_hw.HullWhite*> self._thisptr.get()).calibrate(
            helpers_vector,
            deref(method._thisptr),
            deref(end_criteria._thisptr),
            deref(constraint._thisptr),
            weights,
            fix_parameters
        )

    @staticmethod
    def convexity_bias(Real future_price,
                       Time t,
                       Time T,
                       Real sigma,
                       Real a):
        """Futures convexity bias

        i.e., the difference between futures implied rate and forward rate
        calculated as in [1]_.

        Parameters
        ----------
        t : float
            maturity date of the futures contract
        T : float
            maturity of the underlying Libor deposit
        sigma : float
            annual volatility of the short rate
        a :
           mean-reversion parameter

        Notes
        -----
        `t` and `T` should be expressed in yearfraction using deposit day counter,
        `future_price` is futures' market price.

        .. [1] G. Kirikos, D. Novak, "Convexity Conundrums", Risk Magazine, March 1997.

        """
        return _hw.HullWhite.convexityBias(future_price, t, T, sigma, a)
