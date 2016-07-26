# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Hénaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from cython.operator cimport dereference as deref

from quantlib.handle cimport Handle, shared_ptr
cimport _pricing_engine as _pe
cimport quantlib.models.shortrate._onefactor_model as _ofm

from engine cimport PricingEngine
cimport _swaption

cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
from quantlib.models.shortrate.onefactor_model cimport OneFactorAffineModel
from quantlib.models.shortrate.onefactormodels.hullwhite cimport HullWhite


cdef class JamshidianSwaptionEngine(PricingEngine):

    def __init__(self, HullWhite model,
                 YieldTermStructure ts=None):

        cdef Handle[_yts.YieldTermStructure] yts_handle
        if ts is None:
            yts_handle = Handle[_yts.YieldTermStructure]()
        else:
            yts_handle = deref(ts._thisptr.get())


        self._thisptr = new shared_ptr[_pe.PricingEngine](
            new _swaption.JamshidianSwaptionEngine(
                deref(<shared_ptr[_ofm.OneFactorAffineModel]*> model._thisptr),
                yts_handle))
