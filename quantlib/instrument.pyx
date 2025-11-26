"""Abstract instrument class"""
from quantlib.time.date cimport date_from_qldate
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.ext cimport static_pointer_cast
from quantlib._observable cimport Observable as QlObservable

cdef class Instrument(Observable):
    """Abstract instrument class.

    This class is purely abstract and defines the interface of concrete
    instruments which will be derived from this one.
    """

    def set_pricing_engine(self, PricingEngine engine not None):
        """Sets the pricing engine to be used.

        .. warning::

            Calling this method will have no effects in case the
            `performCalculation` method was overridden in a derived class.

        Parameters
        ----------
        engine : :class:`~quantlib.pricingengines.engine.PricingEngine`
            The pricing engine to be used.
        """
        self._thisptr.get().setPricingEngine(engine._thisptr)

    cdef shared_ptr[QlObservable] as_observable(self) noexcept nogil:
        return static_pointer_cast[QlObservable](self._thisptr)

    property net_present_value:
        """The net present value of the instrument."""
        def __get__(self):
            return self._thisptr.get().NPV()

    @property
    def error_estimate(self):
        """:obj:`Real`: error estimate on the NPV when available"""
        return self._thisptr.get().errorEstimate()

    property npv:
        """A shortcut to the net_present_value property."""
        def __get__(self):
            return self._thisptr.get().NPV()

    @property
    def is_expired(self):
        """:obj:`bool`: whether the instrument might have value greater than zero."""
        return self._thisptr.get().isExpired()

    @property
    def valuation_date(self):
        """:class:`~quantlib.time.date.Date`: the date the net present value refers to."""
        return date_from_qldate(self._thisptr.get().valuationDate())
