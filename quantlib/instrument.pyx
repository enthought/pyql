"""Abstract instrument class"""
from quantlib.time.date cimport date_from_qldate
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.handle cimport static_pointer_cast
from quantlib._observable cimport Observable as QlObservable

cdef class Instrument(Observable):
    """Abstract instrument class

    This class is purely abstract and defines the interface of concrete
    instruments which will be derived from this one.
    """

    def set_pricing_engine(self, PricingEngine engine not None):
        '''Sets the pricing engine.

        '''
        self._thisptr.get().setPricingEngine(engine._thisptr)

    cdef shared_ptr[QlObservable] as_observable(self) noexcept nogil:
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
    def is_expired(self) -> bool:
        """whether the instrument might ave value greater than zero."""
        return self._thisptr.get().isExpired()

    @property
    def valuation_date(self):
        """the date the net present value refers to.

        Returns
        -------
        valuation_date: :class:`~quantlib.time.date.Date`
        """
        return date_from_qldate(self._thisptr.get().valuationDate())
