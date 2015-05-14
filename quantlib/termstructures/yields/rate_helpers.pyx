"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from cython.operator cimport dereference as deref

cimport _rate_helpers as _rh
from quantlib.handle cimport shared_ptr, Handle
cimport quantlib._quote as _qt
cimport quantlib.indexes._ibor_index as _ib
cimport quantlib.indexes._swap_index as _si
from quantlib.time._period cimport Frequency, Days
from quantlib.time._calendar cimport BusinessDayConvention

from quantlib.quotes cimport Quote, SimpleQuote
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Period, Date
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes.swap_index cimport SwapIndex

from quantlib.time.calendar import ModifiedFollowing

cdef class RateHelper:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    property quote:
        def __get__(self):
            cdef shared_ptr[_qt.Quote] quote_ptr = shared_ptr[_qt.Quote](self._thisptr.get().quote().currentLink())
            return quote_ptr.get().value()

    property implied_quote:
        def __get__(self):
            return self._thisptr.get().impliedQuote()


cdef class RelativeDateRateHelper:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    property quote:
        def __get__(self):
            cdef shared_ptr[_qt.Quote] quote_ptr = shared_ptr[_qt.Quote](self._thisptr.get().quote().currentLink())
            return quote_ptr.get().value()

    property implied_quote:
        def __get__(self):
            return self._thisptr.get().impliedQuote()


cdef class DepositRateHelper(RateHelper):
    """Rate helper for bootstrapping over deposit rates. [uses SimpleQuotes] update 05/14/2015"""

    def __init__(self, Quote quote, Period tenor=None, Natural fixing_days=0,
        Calendar calendar=None, int convention=ModifiedFollowing,
        end_of_month=True, DayCounter deposit_day_counter=None,
        IborIndex index=None):
        cdef Handle[_qt.Quote] rate_handle = Handle[_qt.Quote](deref(quote._thisptr))
        
        if index is not None:
            self._thisptr = new shared_ptr[_rh.RateHelper](
                new _rh.DepositRateHelper(
                    rate_handle,
                    deref(<shared_ptr[_ib.IborIndex]*> index._thisptr)
                )
            )
        else:
            self._thisptr = new shared_ptr[_rh.RateHelper](
                new _rh.DepositRateHelper(
                    rate_handle,
                    deref(tenor._thisptr.get()),
                    <int>fixing_days,
                    deref(calendar._thisptr),
                    <_rh.BusinessDayConvention>convention,
                    True,
                    deref(deposit_day_counter._thisptr)
                )
            )
cdef class SwapRateHelper(RelativeDateRateHelper):
    """Rate helper for bootstrapping over swap rates, use from_tenor or from_index function, 
    from_tenor uses SimpleQuote() instead of double""" 
    def __init__(self, from_classmethod=False):
        # Creating a SwaprRateHelper without using a class method means the
        # shared_ptr won't be initialized properly and break any subsequent calls
        # to the QuantLib internals... To avoid this, we raise a ValueError if
        # the user tries to instantiate this class if not setting the
        # from_classmethod. This is an ugly workaround but is ok so far.

        if from_classmethod is False:
            raise ValueError(
                'SwapRateHelpers must be instantiated through the class methods'
                ' from_index or from_tenor'
            )

    cdef set_ptr(self, shared_ptr[_rh.RelativeDateRateHelper]* ptr):
        self._thisptr = ptr

    @classmethod
    def from_tenor(cls, Quote rate, Period tenor,
        Calendar calendar, Frequency fixedFrequency,
        BusinessDayConvention fixedConvention, DayCounter fixedDayCount,
        IborIndex iborIndex, Quote spread=None, Period fwdStart=None):
        
        cdef Handle[_qt.Quote] rate_handle = Handle[_qt.Quote](deref(rate._thisptr))
        cdef Handle[_qt.Quote] spread_handle
#        cdef Handle[_qt.Quote] _rate    #from merge w/ master, might not need this any longer?

        cdef _qt.SimpleQuote* qt 
        cdef shared_ptr[_qt.Quote] ptr
        if isinstance(rate, float):
            qt = new _qt.SimpleQuote(<Rate>rate)
            ptr = deref(new shared_ptr[_qt.Quote](qt))
        elif isinstance(rate, SimpleQuote):
            ptr = deref((<SimpleQuote>rate)._thisptr)

#        _rate = Handle[_qt.Quote](ptr) #from merge w/ master, might not need this any longer?


        cdef SwapRateHelper instance = cls(from_classmethod=True)

        if spread is None:
            instance.set_ptr(new shared_ptr[_rh.RelativeDateRateHelper](
                new _rh.SwapRateHelper(
                    rate_handle,
                    deref(tenor._thisptr.get()),
                    deref(calendar._thisptr),
                    <Frequency> fixedFrequency,
                    <_rh.BusinessDayConvention> fixedConvention,
                    deref(fixedDayCount._thisptr),
                    deref(<shared_ptr[_ib.IborIndex]*> iborIndex._thisptr))
                )
            )
        else:
            spread_handle = Handle[_qt.Quote](deref(spread._thisptr))

            instance.set_ptr(new shared_ptr[_rh.RelativeDateRateHelper](
                new _rh.SwapRateHelper(
                    rate_handle,
                    deref(tenor._thisptr.get()),
                    deref(calendar._thisptr),
                    <Frequency> fixedFrequency,
                    <_rh.BusinessDayConvention> fixedConvention,
                    deref(fixedDayCount._thisptr),
                    deref(<shared_ptr[_ib.IborIndex]*> iborIndex._thisptr),
                    spread_handle,
                    deref(fwdStart._thisptr.get()))
                )
            )

        return instance

    @classmethod
    def from_index(cls, Quote rate, SwapIndex index):

        cdef Handle[_qt.Quote] rate_handle = Handle[_qt.Quote](deref(rate._thisptr))
        cdef Handle[_qt.Quote] spread_handle = Handle[_qt.Quote](shared_ptr[_qt.Quote](new _qt.SimpleQuote(0)))
        cdef Period p = Period(2, Days)


        cdef SwapRateHelper instance = cls(from_classmethod=True)

        instance.set_ptr(new shared_ptr[_rh.RelativeDateRateHelper](
            new _rh.SwapRateHelper(
                rate_handle,
                deref(<shared_ptr[_si.SwapIndex]*>index._thisptr),
                #spread_handle,
                #deref(p._thisptr.get()))
                )
            )
        )

        return instance

cdef class FraRateHelper(RelativeDateRateHelper):
    """ Rate helper for bootstrapping over %FRA rates. """

    def __init__(self, Quote rate, Natural months_to_start,
            Natural months_to_end, Natural fixing_days, Calendar calendar,
            BusinessDayConvention convention, end_of_month,
            DayCounter day_counter):

        cdef Handle[_qt.Quote] rate_handle = Handle[_qt.Quote](deref(rate._thisptr))

        self._thisptr = new shared_ptr[_rh.RelativeDateRateHelper](
            new _rh.FraRateHelper(
                rate_handle,
                months_to_start,
                months_to_end,
                fixing_days,
                deref(calendar._thisptr),
                <_rh.BusinessDayConvention> convention,
                end_of_month,
                deref(day_counter._thisptr),
            )
        )

cdef class FuturesRateHelper(RateHelper):
    """ Rate helper for bootstrapping over IborIndex futures prices. """

    def __init__(self, Quote rate, Date imm_date,
            Natural length_in_months, Calendar calendar,
            BusinessDayConvention convention, end_of_month,
            DayCounter day_counter):

        cdef Handle[_qt.Quote] rate_handle = Handle[_qt.Quote](deref(rate._thisptr))

        self._thisptr = new shared_ptr[_rh.RateHelper](
            new _rh.FuturesRateHelper(
                rate_handle,
                deref(imm_date._thisptr.get()),
                length_in_months,
                deref(calendar._thisptr),
                <_rh.BusinessDayConvention> convention,
                end_of_month,
                deref(day_counter._thisptr),
            )
        )

