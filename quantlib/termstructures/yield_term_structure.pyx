include '../types.pxi'
from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.time._period cimport Frequency
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date, date_from_qldate, Period

from quantlib._compounding cimport Compounding
from quantlib.time.date import Annual

cimport quantlib.termstructures._yield_term_structure as _yts
cimport quantlib._quote as _qt
cimport quantlib._interest_rate as _ir
from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle, static_pointer_cast
from quantlib._observable cimport Observable as QlObservable
cimport quantlib.time._date as _date
cimport quantlib.time._daycounter as _dc
cimport quantlib.time._calendar as _cal
from quantlib.quotes cimport Quote
from quantlib.interest_rate cimport InterestRate

cdef class YieldTermStructure(Observable):

    # FIXME: the relinkable stuff is really ugly. Do we need this on the
    # python side?

    def link_to(self, YieldTermStructure structure not None):
        if structure._thisptr.empty():
            raise ValueError('Term structure not initialized')
        self._thisptr.linkTo(structure._thisptr.currentLink())

    cdef inline _yts.YieldTermStructure* _get_term_structure(self) except NULL:

        if self._thisptr.empty():
            raise ValueError('Term structure not initialized')
        return self._thisptr.currentLink().get()

    cdef shared_ptr[QlObservable] as_observable(self):
        if self._thisptr.empty():
            raise ValueError('Term structure not initialized')
        return static_pointer_cast[QlObservable](self._thisptr.currentLink())

    property extrapolation:
        def __get__(self):
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            return term_structure.allowsExtrapolation()

        def __set__(self, bool flag):
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            if flag:
                term_structure.enableExtrapolation()
            else:
                term_structure.disableExtrapolation()

    def zero_rate(self, d, DayCounter day_counter=None,
                  Compounding compounding=Compounding.Continuous, int frequency=Annual,
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
        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
        cdef _ir.InterestRate ql_zero_rate

        if isinstance(d, Date):
            if day_counter is None:
                raise ValueError("day_counter needs to be provided")
            ql_zero_rate = term_structure.zeroRate(
                deref((<Date>d)._thisptr), deref(day_counter._thisptr),
                compounding, <_ir.Frequency>frequency,
                extrapolate)
        elif isinstance(d, (float, int)):
            ql_zero_rate = term_structure.zeroRate(
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

        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
        cdef _ir.InterestRate ql_forward_rate

        if isinstance(d1, Date) and isinstance(d2, Date):
            if day_counter is None:
                raise ValueError("day_counter can't be None")
            ql_forward_rate = term_structure.forwardRate(
                deref((<Date>d1)._thisptr),
                deref((<Date>d2)._thisptr),
                deref(day_counter._thisptr), compounding,
                <_ir.Frequency>frequency, extrapolate)
        elif isinstance(d1, (float, int)) and isinstance(d2, (float, int)):
            ql_forward_rate = term_structure.forwardRate(
                <Time>d1, <Time>d2, compounding,
                <_ir.Frequency>frequency, extrapolate)
        elif isinstance(d1, Date) and isinstance(d2, Period):
           if day_counter is None:
               raise ValueError("day_counter can't be None")
           ql_forward_rate = term_structure.forwardRate(
               deref((<Date>d1)._thisptr), deref((<Period>d2)._thisptr),
               deref(day_counter._thisptr), compounding,
               <_ir.Frequency>frequency, extrapolate)
        else:
            raise TypeError("d1 and d2 need to be both QuantLib Dates or Times " \
                            "or d1 a Date, and d2 a Period.")

        cdef InterestRate forward_rate = InterestRate.__new__(InterestRate)
        forward_rate._thisptr = ql_forward_rate
        return forward_rate

    def discount(self, value, bool extrapolate=False):
        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()

        cdef double discount_value

        if isinstance(value, Date):
            discount_value = term_structure.discount(
                deref((<Date>value)._thisptr), extrapolate)
        elif isinstance(value, float):
            discount_value = term_structure.discount(
                <Time>value, extrapolate)
        else:
            raise ValueError('Unsupported value type')

        return discount_value

    def time_from_reference(self, Date dt):
        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
        cdef Time time = term_structure.timeFromReference(deref(dt._thisptr))
        return time

    property reference_date:
        def __get__(self):
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef _yts.Date ref_date = term_structure.referenceDate()
            return date_from_qldate(ref_date)

    property max_date:
        def __get__(self):
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef _yts.Date max_date = term_structure.maxDate()
            return date_from_qldate(max_date)

    property max_time:
        def __get__(self):
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef Time max_time = term_structure.maxTime()
            return max_time

    property day_counter:
        def __get__(self):
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef DayCounter dc = DayCounter()
            dc._thisptr = new _dc.DayCounter(term_structure.dayCounter())
            return dc

    property settlement_days:
        def __get__(self):
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef int days = term_structure.settlementDays()
            return days
