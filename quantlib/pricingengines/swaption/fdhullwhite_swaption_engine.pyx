from cython.operator cimport dereference as deref
from quantlib.types cimport Real, Size
from quantlib.handle cimport static_pointer_cast
from quantlib.methods.finitedifferences.solvers.fdmbackwardsolver cimport FdmSchemeDesc
from quantlib.models.shortrate.onefactormodels.hullwhite cimport HullWhite
from quantlib.pricingengines.engine cimport PricingEngine
cimport quantlib.models.shortrate.onefactormodels._hullwhite as _hw
from . cimport _fdhullwhite_swaption_engine as _fdhw

cdef class FdHullWhiteSwaptionEngine(PricingEngine):

    def __init__(self, HullWhite model not None, Size t_grid=100,
                 Size x_grid=100, Size damping_steps=0, Real inv_eps=1e-5, FdmSchemeDesc scheme=FdmSchemeDesc.Douglas()):

        self._thisptr.reset(
            new _fdhw.FdHullWhiteSwaptionEngine(
                static_pointer_cast[_hw.HullWhite](model._thisptr),
                t_grid, x_grid, damping_steps, inv_eps, deref(scheme._thisptr)
            )
        )
