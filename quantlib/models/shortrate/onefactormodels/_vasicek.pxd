#
# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.types cimport Rate, Real

from quantlib.models.shortrate._onefactor_model cimport OneFactorAffineModel

cdef extern from 'ql/models/shortrate/onefactormodels/vasicek.hpp' namespace 'QuantLib' nogil:

    cdef cppclass Vasicek(OneFactorAffineModel):
        Vasicek(Rate r0, Real a, Real b, Real sigma, Real Lambda) except +

        Real a()

        Real b()

        Real Lambda 'lambda'()

        Real sigma()

        Real r0()
