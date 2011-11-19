include '../../types.pxi'
from cython.operator cimport dereference as deref

from libcpp cimport bool as cbool

from quantlib.time._period cimport Frequency
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date, date_from_qldate

from quantlib.compounding import Continuous
from quantlib.time.date import Annual

cimport _flat_forward as ffwd
cimport quantlib._quote as _qt
from quantlib.quotes cimport Quote
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure


cdef class FlatForward(YieldTermStructure):

    def __init__(self,
       Date reference_date=None,
       Quote quote=None,
       int settlement_days=0,
       float forward=0.0,
       Calendar calendar=None,
       DayCounter daycounter=None,
       compounding=Continuous,
       frequency=Annual

    ):

        self.relinkable = False

        #local cdef's
        cdef shared_ptr[_qt.Quote]* quote_ptr
        cdef ffwd.Handle[_qt.Quote]* quote_handle
        cdef ffwd.Date _reference_date

        if reference_date is not None and forward is not None:
            self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                new ffwd.FlatForward(
                    deref(reference_date._thisptr.get()),
                    <ffwd.Rate>forward,
                    deref(daycounter._thisptr),
                    <ffwd.Compounding>compounding,
                    <Frequency>frequency
                )
            )
        elif quote is not None and \
             settlement_days is not None and \
             calendar is not None:

            quote_ptr = quote._thisptr
            quote_handle = new ffwd.Handle[_qt.Quote](quote_ptr.get())

            self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                new ffwd.FlatForward(
                    <ffwd.Natural>settlement_days,
                    deref(calendar._thisptr),
                    deref(quote_handle),
                    deref(daycounter._thisptr),
                    <ffwd.Compounding>compounding,
                    <Frequency>frequency
                )
            )
        elif settlement_days is not None and \
             forward is not None and \
             calendar is not None:
            self._thisptr = new shared_ptr[ffwd.YieldTermStructure](
                new ffwd.FlatForward(
                    <ffwd.Natural>settlement_days,
                    deref(calendar._thisptr),
                    <ffwd.Rate>forward,
                    deref(daycounter._thisptr),
                    <ffwd.Compounding>compounding,
                    <Frequency>frequency
                )
            )
        else:
            raise ValueError('Invalid constructor')



