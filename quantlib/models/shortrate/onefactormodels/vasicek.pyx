# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

"""Vasiceck model"""

from quantlib.types cimport Rate, Real
cimport quantlib.models._model as _mo
from . cimport _vasicek as _va
from quantlib.handle cimport shared_ptr

cdef class Vasicek(OneFactorAffineModel):
    r"""Vasicek model

     defined by

     .. math::
        dr_t = a(b - r_t)dt + \sigma dW_t

     where :math:`a`, :math:`b` and :math:`\sigma` are constants.
     A risk premium :math:`\lambda` can also be specified.
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
        return ("Vasicek model\n"
                f"r0: {self.r0}\ta: {self.a}\tb: {self.b}\tsigma: {self.sigma}\tlambda: {self.Lambda}")

    @property
    def a(self):
        return (<_va.Vasicek*> self._thisptr.get()).a()

    @property
    def b(self):
        return (<_va.Vasicek*> self._thisptr.get()).b()

    @property
    def sigma(self):
        return (<_va.Vasicek*> self._thisptr.get()).sigma()

    @property
    def Lambda(self):
        return (<_va.Vasicek*> self._thisptr.get()).Lambda()

    @property
    def r0(self):
        return (<_va.Vasicek*> self._thisptr.get()).r0()
