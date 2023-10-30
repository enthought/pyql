#
# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
#

cdef extern from 'ql/types.hpp' namespace 'QuantLib' nogil:
    ctypedef int Integer
    ctypedef long BigInteger
    ctypedef unsigned int Natural
    ctypedef unsigned long BigNatural
    ctypedef double Real
    ctypedef double Decimal
    ctypedef size_t Size
    ctypedef double Time
    ctypedef double Rate
    ctypedef double Spread
    ctypedef double Volatility
    ctypedef double DiscountFactor
    ctypedef Real Probability
