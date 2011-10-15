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

cdef class Quote:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass

    property is_valid:
        def __get__(self):
            return self._thisptr.get().isValid()

    property value:
        def __get__(self):
            if self._thisptr.get().isValid():
                return self._thisptr.get().value()
            else:
                return None

cdef class SimpleQuote(Quote):

    def __init__(self, float value=0.0):
        self._thisptr = new shared_ptr[ffwd.Quote](new ffwd.SimpleQuote(value))
        
    def __str__(self):
        return 'Simple Quote: %f' % self._thisptr.get().value()

    property value:
        def __get__(self):
            if self._thisptr.get().isValid():
                return self._thisptr.get().value()
            else:
                return None

        def __set__(self, float value):
            (<ffwd.SimpleQuote*>self._thisptr.get()).setValue(value)


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
        cdef ffwd.shared_ptr[ffwd.YieldTermStructure]* ptr 
        if not self.relinkable:
            print 'Term structure is not relinkable'
        else:
            ptr = new ffwd.shared_ptr[ffwd.YieldTermStructure] \
                (structure._thisptr)
            self._relinkable_ptr.linkTo(deref(ptr))

        return

    def discount(self, value):
        cdef ffwd.YieldTermStructure* term_structure
        if self.relinkable:
            # retrieves the shared_ptr (currentLink()) then gets the
            # term_structure (get())
            term_structure = self._relinkable_ptr.currentLink().get()
        else:
            term_structure = self._thisptr

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
            cdef ffwd.Date ref_date =  self._thisptr.referenceDate()
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
        cdef shared_ptr[ffwd.Quote]* quote_ptr
        cdef ffwd.Handle[ffwd.Quote]* quote_handle
        cdef ffwd.Date _reference_date

        if reference_date is not None and forward is not None:
            self._thisptr = new ffwd.FlatForward(
                deref(reference_date._thisptr), 
                <ffwd.Rate>forward, 
                deref(daycounter._thisptr), 
                <ffwd.Compounding>compounding,
                <Frequency>frequency
            ) 
        elif quote is not None and \
             settlement_days is not None and \
             calendar is not None:

            quote_ptr = quote._thisptr
            quote_handle = new ffwd.Handle[ffwd.Quote](quote_ptr.get())

            self._thisptr = new ffwd.FlatForward(
                <ffwd.Natural>settlement_days,
                deref(calendar._thisptr),
                deref(quote_handle),
                deref(daycounter._thisptr),
                <ffwd.Compounding>compounding,
                <Frequency>frequency
            )
        elif settlement_days is not None and \
             forward is not None and \
             calendar is not None:
            self._thisptr = new ffwd.FlatForward(
                <ffwd.Natural>settlement_days,
                deref(calendar._thisptr), 
                <ffwd.Rate>forward, 
                deref(daycounter._thisptr), 
                <ffwd.Compounding>compounding,
                <Frequency>frequency
            ) 
        else:
            raise ValueError('Invalid constructor')



