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

cdef class YieldTermStructure:

    def __cinit__(self):
        self.relinkable = False
        self._thisptr = NULL
        self._relinkable_ptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
        if self._relinkable_ptr is not NULL:
            del self._relinkable_ptr


    def __init__(self, relinkable=True):
        if relinkable:
            self.relinkable = True
            self._relinkable_ptr = new \
                ffwd.RelinkableHandle[ffwd.YieldTermStructure]()
        else:
            raise ValueError('Invalid constructor (not implemented ?)')

    def link_to(self, YieldTermStructure structure):
        if not self.relinkable:
            print 'Term structure is not relinkable'
        else:
            self._relinkable_ptr.linkTo(deref(structure._thisptr))

        return

    def discount(self, value):
        cdef ffwd.YieldTermStructure* term_structure
        if self.relinkable:
            # retrieves the shared_ptr (currentLink()) then gets the
            # term_structure (get())
            term_structure = self._relinkable_ptr.currentLink().get()
        else:
            term_structure = self._thisptr.get()

        if isinstance(value, Date):
            discount_value =  term_structure.discount(
                deref((<Date>value)._thisptr)
            )
        elif isinstance(value, float):
            discount_value = term_structure.discount(
                <Time>value
            )
        else:
            raise ValueError('Unsupported value type')

        return discount_value


    property reference_date:
        def __get__(self):
            cdef ffwd.Date ref_date = \
                (<ffwd.YieldTermStructure*>self._thisptr.get()).referenceDate()
            return date_from_qldate(ref_date)


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
                    deref(reference_date._thisptr),
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



