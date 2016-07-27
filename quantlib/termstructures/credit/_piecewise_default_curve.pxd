"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr
from quantlib.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper
from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar

cdef extern from 'ql/termstructures/credit/probabilitytraits.hpp' namespace 'QuantLib':

    cdef cppclass HazardRate:
        pass

    cdef cppclass SurvivalProbability:
        pass

    cdef cppclass DefaultDensity:
        pass

cdef extern from 'ql/math/interpolations/all.hpp' namespace 'QuantLib':
    cdef cppclass Linear:
        pass

    cdef cppclass LogLinear:
        pass

    cdef cppclass BackwardFlat:
        pass



cdef extern from 'ql/termstructures/credit/piecewisedefaultcurve.hpp' namespace 'QuantLib':
    cdef cppclass PiecewiseDefaultCurve[T, I](DefaultProbabilityTermStructure):
        PiecewiseDefaultCurve(Date& referenceDate,
                              vector[shared_ptr[DefaultProbabilityHelper]]& instruments,
                              DayCounter& dayCounter,
                              Real accuracy)
        PiecewiseDefaultCurve(Natural settlementDays,
                              Calendar& calendar,
                              vector[shared_ptr[DefaultProbabilityHelper]]& instruments,
                              DayCounter& dayCounter,
                              Real accuracy)
        vector[Time]& times() except +
        vector[Date]& dates() except +
        vector[Real]& data() except +
