# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Hénaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from cython.operator cimport dereference as deref

from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.models.shortrate._onefactor_model as _ofm

from quantlib.pricingengines.engine cimport PricingEngine
from . cimport _jamshidian_swaption_engine as _jse

from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.models.shortrate.onefactormodels.hullwhite cimport HullWhite


cdef class JamshidianSwaptionEngine(PricingEngine):

    def __init__(self, HullWhite model not None,
                 HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr.reset(new _jse.JamshidianSwaptionEngine(
                static_pointer_cast[_ofm.OneFactorAffineModel](model._thisptr),
                ts.handle))
