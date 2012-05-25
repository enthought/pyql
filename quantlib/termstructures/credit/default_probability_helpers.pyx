"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport quantlib.termstructures.credit._credit_helpers as _ci


cdef class CdsHelper:

    cdef _ci.CdsHelper* _thisptr # FIXME: this must be a shared_ptr
