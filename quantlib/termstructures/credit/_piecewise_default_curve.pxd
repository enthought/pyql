"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp.string cimport string

from quantlib.handle cimport shared_ptr
from quantlib.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper
from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter

cdef extern from 'ql/termstructures/credit/probabilitytraits.hpp' namespace 'QuantLib':

    cdef struct HazardRate:
        pass

cdef extern from 'credit_piecewise_support_code.hpp' namespace 'QuantLib':

    cdef shared_ptr[DefaultProbabilityTermStructure] credit_term_structure_factory(
        string& traits,
        string& interpolator,
        Date& reference_date,
        vector[shared_ptr[DefaultProbabilityHelper]]& curve_input,
        DayCounter& day_counter,
        Real tolerance
    ) except +


cdef extern from 'ql/termstructures/credit/piecewisedefaultcurve.hpp' namespace 'QuantLib':

    cdef cppclass PiecewiseDefaultCurve[T, I]:
        pass
        # Not using the constructor because of the missing support for typemaps
        # in Cython --> use only the credit_term_structure_factory!
        #PiecewiseDefaultCurve(
        #    Date& referenceDate,
        #    #std::vector<boost::shared_ptr<typename Traits::helper> >& 
        #    vector[shared_ptr[CdsHelper] ]& instruments, # typename not supported by Cython
        #    DayCounter& dayCounter,
        #    Real accuracy,
        #    #Interpolator& i = Interpolator()
        #)

