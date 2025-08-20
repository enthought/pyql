#
# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.types cimport Rate, Real, Time

from quantlib.handle cimport static_pointer_cast
from quantlib.option cimport OptionType
cimport quantlib.models.shortrate._onefactor_model as _ofm
cimport quantlib._stochastic_process as _sp
from quantlib.stochastic_process cimport StochasticProcess1D

cdef class ShortRateDynamics:
    """Base class describing the short-rate dynamics"""
    @property
    def process(self):
        """Returns the risk_neutral dynamics of the state variable"""
        cdef StochasticProcess1D sp = StochasticProcess1D.__new__(StochasticProcess1D)
        sp._thisptr = static_pointer_cast[_sp.StochasticProcess](self._thisptr.get().process())
        return sp

    def variable(self, Time t, Rate r) -> Real:
        """Compute state variable from short rate"""
        return self._thisptr.get().variable(t, r)

    def short_rate(self, Time t, Real variable):
        """Compute short rate from state variable"""
        return self._thisptr.get().shortRate(t, variable)

cdef class OneFactorModel(ShortRateModel):

    @property
    def dynamics(self):
        """short-rate dynamics

        Returns
        -------
        dynamics : :class:`~quantlib.models.shortrate.onefactor_model.ShortRateDynamics`
        """
        cdef ShortRateDynamics dyn = ShortRateDynamics.__new__(ShortRateDynamics)
        dyn._thisptr =  (<_ofm.OneFactorModel*>self._thisptr.get()).dynamics()
        return dyn

cdef class OneFactorAffineModel(OneFactorModel):
    r"""Single-factor affine base class

    Single-factor models with an analytical formula for discount bonds
    should inherit from this class. They must then implement the functions
    :math:`A(T,t)` and :math:`B(T,t)` such that

    .. math::
        P(t, T, r_t) = A(t, T)\exp\{-B(t, T) r_t\}.
    """

    def __init__(self):
        raise ValueError('Cannot instantiate OneFactorAffineModel')

    def discount_bond(self, Time now, Time maturity, Rate rate):
        return (<_ofm.OneFactorAffineModel*>self._thisptr.get()).discountBond(
        now, maturity, rate)

    def discount_bond_option(self, OptionType option_type, Real strike, Time maturity, Time bond_maturity):
        return (<_ofm.OneFactorAffineModel*>self._thisptr.get()).discountBondOption(
            option_type, strike, maturity, bond_maturity)
