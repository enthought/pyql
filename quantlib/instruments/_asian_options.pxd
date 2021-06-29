include '../types.pxi'

from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date

from quantlib.instruments._exercise cimport Exercise
from quantlib.instruments._option cimport OneAssetOption
from quantlib.instruments._payoffs cimport StrikedTypePayoff


# Placeholder for enumerated averaging types
cdef extern from 'ql/instruments/averagetype.hpp' namespace 'QuantLib::Average':
    enum Type:
        Arithmetic 
        Geometric
    

cdef extern from 'ql/instruments/asianoption.hpp' namespace 'QuantLib':
    # Continuous-averaging Asian option
    #    TODO add running average
    #    ingroup: instruments
    #
    cdef cppclass ContinuousAveragingAsianOption(OneAssetOption):

        ContinuousAveragingAsianOption(
                Type averageType,
                shared_ptr[StrikedTypePayoff]& payoff,
                shared_ptr[Exercise]& exercise) except +

       
    cdef cppclass DiscreteAveragingAsianOption(OneAssetOption):
        # Discrete-averaging Asian option
        #    ingroup: instruments 
        #    This constructor takes the running sum or product of past fixings,
        #    depending on the average type.  The fixing dates passed here can be
        #    only the future ones.
        
        DiscreteAveragingAsianOption(Type averageType,
                                     Real runningAccumulator,
                                     Size pastFixings,
                                     vector[Date] fixingDates,
                                     shared_ptr[StrikedTypePayoff]& payoff,
                                     shared_ptr[Exercise]& exercise) except +

        # This constructor takes past fixings as a vector, defaulting to an empty
        #    vector representing an unseasoned option.  This constructor expects *all* fixing dates
        #    to be provided, including those in the past, and to be already sorted.  During the
        #    calculations, the option will compare them to the evaluation date to determine which
        #    are historic; it will then take as many values from allPastFixings as needed and ignore
        #    the others.  If not enough fixings are provided, it will raise an error.
        
        DiscreteAveragingAsianOption(Type averageType,
                                     vector[Date] fixingDates,
                                     shared_ptr[StrikedTypePayoff]& payoff,
                                     shared_ptr[Exercise]& exercise,
                                     vector[Real] allPastFixings) except +
