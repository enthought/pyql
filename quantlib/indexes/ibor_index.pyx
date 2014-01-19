include '../types.pxi'
from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.currency cimport Currency
from quantlib.time.calendar cimport Calendar
from quantlib.time._calendar cimport ModifiedFollowing
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
cimport quantlib._index as _in
cimport quantlib.indexes._ibor_index as _ib
from quantlib.indexes.libor cimport Libor
from quantlib.indexes.euribor cimport Euribor

from quantlib.market.conventions.swap import SwapData

cdef extern from "string" namespace "std":
    cdef cppclass string:
        char* c_str()

from quantlib.indexes.interest_rate_index cimport InterestRateIndex

cdef class IborIndex(InterestRateIndex):
    def __cinit__(self):
        pass

    property businessDayConvention:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.businessDayConvention()

    property endOfMonth:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.endOfMonth()

    @classmethod
    def from_name(self, market, **kwargs):
        """
        Create default IBOR for the market, modify attributes if provided
        """

        row = SwapData.params(market)
        row = row._replace(**kwargs)
        
        # could use a dummy term structure here?
        term_structure = YieldTermStructure(relinkable=False)
        # may not be needed at this stage...
        # term_structure.link_to(FlatForward(settlement_date, 0.05,
        #                                       Actual365Fixed()))

        if row.currency == 'EUR':
            ibor_index = Euribor(Period(row.floating_leg_period), term_structure)
        else:
            label = row.currency + ' ' + row.floating_leg_reference
            ibor_index = Libor(label,
                               Period(row.floating_leg_period),
                               row.fixing_days,
                               Currency.from_name(row.currency),
                               Calendar.from_name(row.calendar),
                               DayCounter.from_name(row.floating_leg_daycount),
                               term_structure)
            
        return ibor_index


cdef class OvernightIndex(IborIndex):
    def __cinit__(self):
        pass

