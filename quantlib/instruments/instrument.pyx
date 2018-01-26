from cython.operator cimport dereference as deref
from quantlib.time.date cimport date_from_qldate
from quantlib.pricingengines.engine cimport PricingEngine

cdef class Instrument:

    def __cinit__(self):
        self._thisptr = NULL
        self._has_pricing_engine = False

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def set_pricing_engine(self, PricingEngine engine not None):
        '''Sets the pricing engine.

        '''
        self._thisptr.get().setPricingEngine(deref(engine._thisptr))


    property net_present_value:
        """ Instrument net present value. """
        def __get__(self):
            return self._thisptr.get().NPV()

    property npv:
        """ Shortcut to the net_present_value property. """
        def __get__(self):
            return self._thisptr.get().NPV()

    @property
    def valuation_date(self):
        return date_from_qldate(self._thisptr.get().valuationDate())
