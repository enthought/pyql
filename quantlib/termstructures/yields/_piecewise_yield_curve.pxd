include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp.pair cimport pair

from quantlib.handle cimport shared_ptr
from quantlib.time._calendar cimport Calendar
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from ._rate_helpers cimport RateHelper
from .._iterativebootstrap cimport IterativeBootstrap

cdef extern from 'ql/termstructures/yield/piecewiseyieldcurve.hpp' namespace 'QuantLib':
    cdef cppclass PiecewiseYieldCurve[T, I, B=*](YieldTermStructure):
        ctypedef IterativeBootstrap[PiecewiseYieldCurve[T, I]] bootstrap_type
        PiecewiseYieldCurve(Date& referenceDate,
                            vector[shared_ptr[RateHelper]]& instruments,
                            const DayCounter& dayCounter,
                            const I&, # = I(),
                            bootstrap_type bootstrap,
                            ) except +
        PiecewiseYieldCurve(Natural settlementDays,
                            Calendar& calendar,
                            vector[shared_ptr[RateHelper]]& instruments,
                            DayCounter& dayCounter,
                            const I&, # = I(),
                            bootstrap_type bootstrap,
                            ) except +
        vector[Time]& times() except +
        vector[Date]& dates() except +
        vector[Real]& data() except +
        vector[pair[Date, Real]]& nodes()
