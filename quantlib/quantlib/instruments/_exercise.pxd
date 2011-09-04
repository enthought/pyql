include '../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.time._date cimport Date

cdef extern from 'ql/exercise.hpp' namespace 'QuantLib::Exercise':

    cdef enum Type:
        American
        Bermudan
        European


cdef extern from 'ql/exercise.hpp' namespace 'QuantLib':

    cdef cppclass Exercise:
        # fixme: I had to add an empty constructor to prevent the following
        # error :
        # _option.pxd:50:25: no matching function for call to 
        # Exercise::Exercise()
        Exercise()
        Exercise(Type type)
        Type type()

    cdef cppclass EarlyExercise(Exercise):
        # fixme: same issue as with the Exercise class
        EarlyExercise()
        EarlyExercise(Type type)
        EarlyExercise(Type type, payoffAtExpiry)

    cdef cppclass AmericanExercise(EarlyExercise):
        AmericanExercise(Date& earliestDate, Date& latestDate)
        AmericanExercise(Date& earliestDate, Date& latestDate, bool payoffAtExpiry)
        AmericanExercise(Date& latestDate, bool payoffAtExpiry)
        AmericanExercise(Date& latestDate)

    cdef cppclass BermudanExercise(EarlyExercise):
        BermudanExercise(vector[Date]& dates)
        BermudanExercise(vector[Date]& dates, payoffAtExpiry)

    cdef cppclass EuropeanExercise(Exercise):
        EuropeanExercise(Date& date)

