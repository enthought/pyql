include '../../types.pxi'

from quantlib.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._calendar cimport Calendar
from quantlib.handle cimport Handle
from quantlib._quote cimport Quote

cdef extern from 'ql/termstructures/credit/flathazardrate.hpp' namespace 'QuantLib':

    cdef cppclass FlatHazardRate(DefaultProbabilityTermStructure):
        FlatHazardRate(const Date& referenceDate,
                       const Handle[Quote]& hazardRate,
                       const DayCounter&)
        FlatHazardRate(const Date& referenceDate,
                       Rate hazardRate,
                       const DayCounter&)
        FlatHazardRate(Natural settlementDays,
                       const Calendar& calendar,
                       const Handle[Quote]& hazardRate,
                       const DayCounter&)
        FlatHazardRate(Natural settlementDays,
                       const Calendar& calendar,
                       Rate hazardRate,
                       const DayCounter&)
