"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.indexes.interest_rate_index cimport InterestRateIndex

cdef class IborIndex(InterestRateIndex):
    pass


cdef class OvernightIndex(IborIndex):
    pass
