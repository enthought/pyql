include '../../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, Handle

from quantlib.termstructures.default_term_structure cimport DefaultProbabilityTermStructure

cimport quantlib.termstructures.credit._flat_hazardrate as _fhr
cimport quantlib.termstructures._default_term_structure as _dts
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar
cimport quantlib._quote as _qt
from quantlib.quotes cimport SimpleQuote

cdef class FlatHazardRate(DefaultProbabilityTermStructure):
    def __init__(self, int settlement_days,  Calendar calendar not None,
                 hazard_rate, DayCounter day_counter not None):
        if isinstance(hazard_rate, float):
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _fhr.FlatHazardRate(settlement_days,
                                        deref(calendar._thisptr),
                                        <Rate>hazard_rate,
                                        deref(day_counter._thisptr)))
        elif isinstance(hazard_rate, SimpleQuote):
            self._thisptr = shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _fhr.FlatHazardRate(
                    settlement_days,
                    deref(calendar._thisptr),
                    Handle[_qt.Quote](deref((<SimpleQuote>hazard_rate)._thisptr)),
                    deref(day_counter._thisptr)))
        else:
            raise TypeError("hazard_rate needs to be a float or a Quote")

    @classmethod
    def from_reference_date(cls, Date reference_date not None, double hazard_rate,
                            DayCounter day_counter not None):
        cdef FlatHazardRate instance = cls.__new__(cls)
        if isinstance(hazard_rate, float):
            instance._thisptr =  shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _fhr.FlatHazardRate(deref(reference_date._thisptr.get()),
                                        <Rate>hazard_rate,
                                        deref(day_counter._thisptr)))
        elif isinstance(hazard_rate, SimpleQuote):
             instance._thisptr =  shared_ptr[_dts.DefaultProbabilityTermStructure](
                new _fhr.FlatHazardRate(
                    deref(reference_date._thisptr.get()),
                    Handle[_qt.Quote](deref((<SimpleQuote>hazard_rate)._thisptr)),
                    deref(day_counter._thisptr)))
        else:
            raise TypeError("hazard_rate needs to be a float or a Quote")
        return instance
