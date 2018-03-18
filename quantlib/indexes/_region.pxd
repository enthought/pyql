"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string


cdef extern from 'ql/indexes/region.hpp' namespace 'QuantLib':

    cdef cppclass Region nogil:
        Region()
        Region(Region&)
        string name()
        string code()
        
    cdef cppclass CustomRegion(Region):
        CustomRegion()
        CustomRegion(string& name,
                     string& code) except +

    cdef cppclass AustraliaRegion(Region):
        AustraliaRegion()

    cdef cppclass EURegion(Region):
        EuRegion()

    cdef cppclass FranceRegion(Region):
        FranceRegion()
        
    cdef cppclass UKRegion(Region):
        UKRegion()

    cdef cppclass USRegion(Region):
        USRegion()
