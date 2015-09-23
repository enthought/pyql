"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../../types.pxi'

from libcpp.vector cimport vector
from quantlib.math._optimization cimport OptimizationMethod, EndCriteria
from quantlib.models.shortrate.calibrationhelpers._swaption_helper cimport SwaptionHelper
from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures.yields._flat_forward cimport YieldTermStructure
from quantlib.instruments._option cimport Type as OptionType
from quantlib.models.shortrate.onefactormodels._vasicek cimport Vasicek

cdef extern from 'ql/models/shortrate/onefactormodels/hullwhite.hpp' namespace 'QuantLib':

    cdef cppclass HullWhite(Vasicek):

        HullWhite() # fake empty constructor due to Cython issue
        HullWhite(
            Handle[YieldTermStructure]& termStructure,
            Real a, Real sigma) except +

        # shared_ptr[Lattice] tree(TimeGrid& grid)
        # shared_ptr[ShortRateDynamics] dynamics()
        
        Real discountBondOption(OptionType type,
                                Real strike,
                                Time maturity,
                                Time bondMaturity) except +

        Real discountBondOption(OptionType type,
                                Real strike,
                                Time maturity,
                                Time bondStart,
                                Time bondMaturity) except +

        Rate convexityBias(Real futurePrice,
                           Time t,
                           Time T,
                           Real sigma,
                           Real a) except +

        void calibrate(
               vector[shared_ptr[SwaptionHelper]]&,
               OptimizationMethod& method,
               EndCriteria& endCriteria,
        ) except +
