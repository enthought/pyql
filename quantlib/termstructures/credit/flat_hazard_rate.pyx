from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure

cimport quantlib.termstructures.credit._flat_hazardrate as _fhr
cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar

cdef class FlatHazardRate(DefaultProbabilityTermStructure):
    def __init__(self, int settlement_days,  Calendar calendar not None,
                 double hazard_rate, DayCounter day_counter not None):
        self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
            new _fhr.FlatHazardRate(settlement_days, deref(calendar._thisptr),
                                    hazard_rate, deref(day_counter._thisptr)))

    @classmethod
    def from_reference_date(cls, Date reference_date not None, double hazard_rate,
                            DayCounter day_counter not None):
        cdef FlatHazardRate instance = cls.__new__(cls)
        instance._thisptr =  shared_ptr[_dts.DefaultProbabilityTermStructure](
            new _fhr.FlatHazardRate(deref(reference_date._thisptr.get()), hazard_rate,
                                    deref(day_counter._thisptr)))
        return instance
