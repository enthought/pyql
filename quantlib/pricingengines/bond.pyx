"""
 Copyright (C) 2011, Enthought Inc

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from cython.operator cimport dereference as deref

from quantlib.handle cimport Handle, shared_ptr
from .cimport _pricing_engine as _pe
from . cimport _bond

from .engine cimport PricingEngine

cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cdef class DiscountingBondEngine(PricingEngine):

    def __init__(self, YieldTermStructure discount_curve):
        """
        """

        self._thisptr.reset(new _bond.DiscountingBondEngine(discount_curve._thisptr))
