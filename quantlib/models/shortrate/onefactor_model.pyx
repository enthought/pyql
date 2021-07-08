"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from quantlib.handle cimport static_pointer_cast
from quantlib.models.model cimport CalibratedModel
cimport quantlib.models.shortrate._onefactor_model as _ofm
cimport quantlib._stochastic_process as _sp
from quantlib.stochastic_process cimport StochasticProcess1D

cdef class ShortRateDynamics:

    @property
    def process(self):
        cdef StochasticProcess1D sp = StochasticProcess1D.__new__(StochasticProcess1D)
        sp._thisptr = static_pointer_cast[_sp.StochasticProcess](self._thisptr.get().process())
        return sp

    def variable(self, Time t, Rate r):
        return self._thisptr.get().variable(t, r)

    def short_rate(self, Time t, Real variable):
        return self._thisptr.get().shortRate(t, variable)

cdef class OneFactorAffineModel(CalibratedModel):

    def __init__(self):
        raise ValueError('Cannot instantiate OneFactorAffineModel')

    def discount_bound(self, Time now, Time maturity, Rate rate):
        return (<_ofm.OneFactorAffineModel*>self._thisptr.get()).discountBond(
            now, maturity, rate)

    @property
    def dynamics(self):
        cdef ShortRateDynamics dyn = ShortRateDynamics.__new__(ShortRateDynamics)
        dyn._thisptr =  (<_ofm.OneFactorAffineModel*>self._thisptr.get()).dynamics()
        return dyn
