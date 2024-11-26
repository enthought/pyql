# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.types cimport Rate, Real, Time
from quantlib.handle cimport Handle
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.instruments.option cimport OptionType
from ._vasicek cimport Vasicek
from ..._model cimport TermStructureConsistentModel

cdef extern from 'ql/models/shortrate/onefactormodels/hullwhite.hpp' namespace 'QuantLib' nogil:

    cdef cppclass HullWhite(Vasicek, TermStructureConsistentModel):
        HullWhite(
            Handle[YieldTermStructure]& termStructure,
            Real a, Real sigma) except +

        @staticmethod
        Rate convexityBias(Real futurePrice,
                           Time t,
                           Time T,
                           Real sigma,
                           Real a) except +
