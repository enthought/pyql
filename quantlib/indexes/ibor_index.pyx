include '../types.pxi'
from cython.operator cimport dereference as deref
from libcpp.string cimport string

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency.currency cimport Currency
from quantlib.time.calendar cimport Calendar
from quantlib.time._calendar cimport ModifiedFollowing
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
cimport quantlib._index as _in
cimport quantlib.indexes._ibor_index as _ib

from quantlib.time import calendar_from_name

from quantlib.conventions import params as swap_params
from quantlib.indexes.interest_rate_index cimport InterestRateIndex

cdef class IborIndex(InterestRateIndex):
    def __cinit__(self):
        pass

    property business_day_convention:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.businessDayConvention()

    property end_of_month:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.endOfMonth()

    @classmethod
    def from_name(self, market, term_structure=None, **kwargs):
        """
        Create default IBOR for the market, modify attributes if provided
        """

        row = swap_params(market)
        row = row._replace(**kwargs)

        if row.currency == 'EUR':
            from quantlib.indexes.euribor import Euribor
            ibor_index = Euribor(Period(row.floating_leg_period), term_structure)
        else:
            label = row.currency + ' ' + row.floating_leg_reference
            from quantlib.indexes.libor import Libor
            ibor_index = Libor(label,
                               Period(row.floating_leg_period),
                               row.settlement_days,
                               Currency.from_name(row.currency),
                               calendar_from_name(row.calendar),
                               DayCounter.from_name(row.floating_leg_daycount),
                               term_structure)

        return ibor_index


cdef class OvernightIndex(IborIndex):
    def __cinit__(self):
        pass

