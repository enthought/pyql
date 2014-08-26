"""
 Copyright (C) 2011, Enthought Inc

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from libcpp cimport bool

from quantlib.pricingengines._pricing_engine cimport PricingEngine
from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'boost/optional.hpp' namespace 'boost':
    cdef cppclass optional[T]:
        optional(T*)

cdef extern from 'ql/pricingengines/bond/discountingbondengine.hpp' namespace \
    'QuantLib':

    cdef cppclass DiscountingBondEngine(PricingEngine):

        DiscountingBondEngine()
        DiscountingBondEngine(Handle[YieldTermStructure]& discountCurve)
        DiscountingBondEngine(Handle[YieldTermStructure]& discountCurve,
                optional[bool] includeSttlementDateFlows)


