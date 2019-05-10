"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from cython.operator cimport dereference as deref

from quantlib.models.shortrate.onefactor_model cimport OneFactorAffineModel
cimport quantlib.models._model as _mo
from . cimport _vasicek as _va
from quantlib.handle cimport Handle, shared_ptr
cimport quantlib._quote as _qt
from quantlib.quotes cimport Quote, SimpleQuote

cdef class Vasicek(OneFactorAffineModel):
    """
    Vasicek model defined by
    .. math::
    dr_t = a(b - r_t)dt + \sigma dW_t

    where a, b and sigma are constants.
    A risk premium lambda can also be specified.
    """

    def __init__(self,
       Rate r0,
       Real a=0,
       Real b=0,
       Real sigma=0,
       Real Lambda=0):

        self._thisptr = shared_ptr[_mo.CalibratedModel](
            new _va.Vasicek(
                r0, a, b, sigma, Lambda
		)
	)

    def __str__(self):
        return 'Vasicek model\na: %f b: %f sigma: %f lambda: %f' % \
          (self.r0, self.a, self.b, self.sigma, self.Lambda)

    property a:
        def __get__(self):
            return (<_va.Vasicek*> self._thisptr.get()).a()

    property b:
        def __get__(self):
            return (<_va.Vasicek*> self._thisptr.get()).b()

    property sigma:
        def __get__(self):
            return (<_va.Vasicek*> self._thisptr.get()).sigma()

    property Lambda:
        def __get__(self):
            return (<_va.Vasicek*> self._thisptr.get()).Lambda()
