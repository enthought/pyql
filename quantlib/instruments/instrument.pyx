from cython.operator cimport dereference as deref
from quantlib.time.date cimport date_from_qldate
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.handle cimport static_pointer_cast
from quantlib._observable cimport Observable as QlObservable

cdef class Instrument(Observable):

    def set_pricing_engine(self, PricingEngine engine not None):
        '''Sets the pricing engine.

        '''
        self._thisptr.get().setPricingEngine(engine._thisptr)

    cdef shared_ptr[QlObservable] as_observable(self):
        return static_pointer_cast[QlObservable](self._thisptr)

    property net_present_value:
        """ Instrument net present value. """
        def __get__(self):
            return self._thisptr.get().NPV()

    property npv:
        """ Shortcut to the net_present_value property. """
        def __get__(self):
            return self._thisptr.get().NPV()

    @property
    def is_expired(self):
        return self._thisptr.get().isExpired()

    @property
    def valuation_date(self):
        return date_from_qldate(self._thisptr.get().valuationDate())
