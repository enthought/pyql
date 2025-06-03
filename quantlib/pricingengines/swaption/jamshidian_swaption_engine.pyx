# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Hénaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.ext cimport shared_ptr, static_pointer_cast
cimport quantlib.pricingengines._pricing_engine as _pe
cimport quantlib.models.shortrate._onefactor_model as _ofm

from quantlib.pricingengines.engine cimport PricingEngine
from . cimport _jamshidian_swaption_engine as _jse

from quantlib.handle cimport HandleYieldTermStructure
from quantlib.models.shortrate.onefactor_model cimport OneFactorAffineModel


cdef class JamshidianSwaptionEngine(PricingEngine):

    def __init__(self, OneFactorAffineModel model not None,
                 HandleYieldTermStructure ts=HandleYieldTermStructure()):

        self._thisptr.reset(new _jse.JamshidianSwaptionEngine(
                static_pointer_cast[_ofm.OneFactorAffineModel](model._thisptr),
                ts.handle()))
