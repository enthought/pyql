"""
 Copyright (C) 2011, Enthought Inc

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from . cimport _discountingbondengine as _dbe

from ..engine cimport PricingEngine

from quantlib.termstructures.yield_term_structure cimport YieldTermStructure

cdef class DiscountingBondEngine(PricingEngine):

    def __init__(self, YieldTermStructure discount_curve):
        """
        """

        self._thisptr.reset(new _dbe.DiscountingBondEngine(discount_curve._thisptr))
