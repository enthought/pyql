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

    # FIXME: the relinkable stuff is really ugly. Do we need this on the python
    # side?

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
                shared_ptr[ffwd.RelinkableHandle[ffwd.YieldTermStructure]]()
            print 'Relinkable termstructure initialized'
        else:
            # initialize an empty shared_ptr. ! Might be dangerous
            self._thisptr = new shared_ptr[ffwd.YieldTermStructure]()

    def link_to(self, YieldTermStructure structure):
        if not self.relinkable:
            print 'Term structure is not relinkable'
        else:
            self._relinkable_ptr.get().linkTo(deref(structure._thisptr))

        return
    
#    def zeroRate(self, dt, dayCounter, comp, freq, extrapolate):
#        """
#        InterestRate YieldTermStructure::zeroRate(const Date& d,
#                                              const DayCounter& dayCounter,
#                                              Compounding comp,
#                                              Frequency freq, bool extrapolate)
#        """
#        cdef shared_ptr[ffwd.YieldTermStructure] ts_ptr
#        if self.relinkable is True:
            # retrieves the shared_ptr (currentLink()) then gets the
            # term_structure (get())
#            ts_ptr = shared_ptr[ffwd.YieldTermStructure](self._relinkable_ptr.get().currentLink())
#            term_structure = ts_ptr.get()
#        else:
#            term_structure = self._thisptr.get()
    
#        zero_rate = term_structure.zeroRate(dt, dayCounter, comp, freq, extrapolate)
        
#        return zero_rate
        
    def discount(self, value):
        cdef ffwd.YieldTermStructure* term_structure
        cdef shared_ptr[ffwd.YieldTermStructure] ts_ptr
        if self.relinkable is True:
            # retrieves the shared_ptr (currentLink()) then gets the
            # term_structure (get())
            ts_ptr = shared_ptr[ffwd.YieldTermStructure](self._relinkable_ptr.get().currentLink())
            term_structure = ts_ptr.get()
        else:
            term_structure = self._thisptr.get()

        if isinstance(value, Date):
            discount_value =  term_structure.discount(
                deref((<Date>value)._thisptr.get())
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
            cdef ffwd.Date ref_date = self._thisptr.get().referenceDate()
            return date_from_qldate(ref_date)


