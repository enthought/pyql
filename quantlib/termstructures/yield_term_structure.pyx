from quantlib.types cimport Time
from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.time.frequency cimport Frequency, Annual
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date, date_from_qldate, Period

from quantlib.compounding cimport Compounding

cimport quantlib.termstructures._yield_term_structure as _yts
cimport quantlib._quote as _qt
cimport quantlib._interest_rate as _ir
from quantlib.handle cimport static_pointer_cast
cimport quantlib.time._date as _date
cimport quantlib.time._daycounter as _dc
cimport quantlib.time._calendar as _cal
from quantlib.quote cimport Quote
from quantlib.interest_rate cimport InterestRate

cdef class YieldTermStructure(TermStructure):

    cdef inline _yts.YieldTermStructure* as_yts_ptr(self) except NULL:
        if not self._thisptr:
            raise ValueError('Term structure not initialized')
        return <_yts.YieldTermStructure*>self._thisptr.get()

    property extrapolation:
        def __get__(self):
            return self.as_yts_ptr().allowsExtrapolation()

        def __set__(self, bool flag):
            if flag:
                self.as_yts_ptr().enableExtrapolation()
            else:
                self.as_yts_ptr().disableExtrapolation()

    def zero_rate(self, d, DayCounter day_counter=None,
                  Compounding compounding=Compounding.Continuous, Frequency frequency=Annual,
                  bool extrapolate=False):
        """ Returns the implied zero-yield rate for the given date.

        The time is calculated as a fraction of year from the reference date.

        Parameters
        ----------
        d : :class:`~quantlib.time.date.Date` or Time
            Time or date used to calcule the zero-yield rate.
        day_counter : :class:`~quantlib.time.daycounter.DayCounter`
            The day counter used to compute the time.
        compounding : int
            The compounding as defined in quantlib.compounding
        frequency : int
            A frequency as defined in quantlib.time.date
        extrapolate : bool, optional
            Default to False

        """
        cdef _ir.InterestRate ql_zero_rate

        if isinstance(d, Date):
            if day_counter is None:
                raise ValueError("day_counter needs to be provided")
            ql_zero_rate = self.as_yts_ptr().zeroRate(
                (<Date>d)._thisptr, deref(day_counter._thisptr),
                compounding, <_ir.Frequency>frequency,
                extrapolate)
        elif isinstance(d, (float, int)):
            ql_zero_rate = self.as_yts_ptr().zeroRate(
                <Time>d, compounding, <_ir.Frequency>frequency,
                extrapolate)
        else:
            raise TypeError("d needs to be a QuantLib Date or a float.")

        cdef InterestRate zero_rate = InterestRate.__new__(InterestRate)
        zero_rate._thisptr = ql_zero_rate

        return zero_rate

    def forward_rate(
            self, d1, d2, DayCounter day_counter=None,
            Compounding compounding=Compounding.Continuous,
            int frequency=Annual, bool extrapolate=False):
        """ Returns the forward interest rate between two dates or times.

        In the former case, times are calculated as fractions of year from the
        reference date. If both dates (times) are equal the instantaneous
        forward rate is returned.

        Parameters
        ----------
        d1 : :class:`~quantlib.time.date.Date` or Time.
            The start date or time used to calculate the forward rate.
        d2 : :class:`~quantlib.time.date.Date` or Time or :class:`~quantlib.time.date.Period`
            The end date, time or period used to calculate the forward rate.
        day_counter : :class:`~quantlib.time.daycounter.DayCounter`
            The day counter used to compute the time.
        compounding : int
            The compounding as defined in quantlib.compounding
        frequency : int
            A frequency as defined in :mod:`quantlib.time.date`
        extrapolate : bool, optional
            Default to False

        """

        cdef _ir.InterestRate ql_forward_rate

        if isinstance(d1, Date) and isinstance(d2, Date):
            if day_counter is None:
                raise ValueError("day_counter can't be None")
            ql_forward_rate = self.as_yts_ptr().forwardRate(
                (<Date>d1)._thisptr,
                (<Date>d2)._thisptr,
                deref(day_counter._thisptr), compounding,
                <_ir.Frequency>frequency, extrapolate)
        elif isinstance(d1, (float, int)) and isinstance(d2, (float, int)):
            ql_forward_rate = self.as_yts_ptr().forwardRate(
                <Time>d1, <Time>d2, compounding,
                <_ir.Frequency>frequency, extrapolate)
        elif isinstance(d1, Date) and isinstance(d2, Period):
           if day_counter is None:
               raise ValueError("day_counter can't be None")
           ql_forward_rate = self.as_yts_ptr().forwardRate(
               (<Date>d1)._thisptr, deref((<Period>d2)._thisptr),
               deref(day_counter._thisptr), compounding,
               <_ir.Frequency>frequency, extrapolate)
        else:
            raise TypeError("d1 and d2 need to be both QuantLib Dates or Times " \
                            "or d1 a Date, and d2 a Period.")

        cdef InterestRate forward_rate = InterestRate.__new__(InterestRate)
        forward_rate._thisptr = ql_forward_rate
        return forward_rate

    def discount(self, value, bool extrapolate=False):
        cdef double discount_value

        if isinstance(value, Date):
            discount_value = self.as_yts_ptr().discount(
                (<Date>value)._thisptr, extrapolate)
        elif isinstance(value, float):
            discount_value = self.as_yts_ptr().discount(
                <Time>value, extrapolate)
        else:
            raise ValueError('Unsupported value type')

        return discount_value


cdef class HandleYieldTermStructure:
    def __init__(self, YieldTermStructure ts=None, bool register_as_observer=True):
        if ts is not None:
            self.handle = RelinkableHandle[_yts.YieldTermStructure](
                static_pointer_cast[_yts.YieldTermStructure](ts._thisptr),
                register_as_observer)

    @property
    def current_link(self):
        cdef YieldTermStructure instance = YieldTermStructure.__new__(YieldTermStructure)
        if self.handle.empty():
            raise ValueError("empty handle")
        instance._thisptr = self.handle.currentLink()
        return instance

    def link_to(self, YieldTermStructure yts, bool register_as_observer=True):
        self.handle.linkTo(static_pointer_cast[_yts.YieldTermStructure](yts._thisptr), register_as_observer)
