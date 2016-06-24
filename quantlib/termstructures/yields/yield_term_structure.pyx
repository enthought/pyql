include '../../types.pxi'
from cython.operator cimport dereference as deref

from libcpp cimport bool
from libcpp.vector cimport vector

from quantlib.time._period cimport Frequency
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.date cimport Date, date_from_qldate

from quantlib.compounding import Continuous
from quantlib.time.date import Annual

cimport quantlib.termstructures._yield_term_structure as _yts
cimport quantlib._quote as _qt
cimport quantlib._interest_rate as _ir
from quantlib.handle cimport Handle, shared_ptr, RelinkableHandle
cimport quantlib.time._date as _date
cimport quantlib.time._daycounter as _dc
cimport quantlib.time._calendar as _cal
from quantlib.quotes cimport Quote
from quantlib.interest_rate cimport InterestRate

cdef class YieldTermStructure:

    # FIXME: the relinkable stuff is really ugly. Do we need this on the
    # python side?

    def __cinit__(self):
        self.relinkable = False
        self._thisptr = NULL

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __init__(self, relinkable=True):
        if relinkable:
            self.relinkable = True
            # Create a new RelinkableHandle to a YieldTermStructure within a
            # new shared_ptr
            self._thisptr = <shared_ptr[Handle[_yts.YieldTermStructure]]*> new \
                shared_ptr[RelinkableHandle[_yts.YieldTermStructure]](
                    new RelinkableHandle[_yts.YieldTermStructure]()
                )
        else:
            self._thisptr = new shared_ptr[Handle[_yts.YieldTermStructure]](
                new Handle[_yts.YieldTermStructure]()
            )

    def link_to(self, YieldTermStructure structure):
        cdef RelinkableHandle[_yts.YieldTermStructure]* rh
        if not self.relinkable:
            raise ValueError('Non relinkable term structure !')
        else:
            rh = <RelinkableHandle[_yts.YieldTermStructure]*>self._thisptr.get()
            rh.linkTo(
                structure._thisptr.get().currentLink()
            )

        return

    cdef _yts.YieldTermStructure* _get_term_structure(self):

        cdef _yts.YieldTermStructure* term_structure
        cdef shared_ptr[_yts.YieldTermStructure] ts_ptr
        ts_ptr = shared_ptr[_yts.YieldTermStructure](
                self._thisptr.get().currentLink()
        )
        term_structure = ts_ptr.get()

        if term_structure is NULL:
            raise ValueError('Term structure not intialized')

        return term_structure

    cdef _is_empty(self):

        return self._thisptr.get().empty()

    cdef _raise_if_empty(self):
        # verify that the handle is not empty. We could add an except + on the
        # definition of the currentLink() method but it creates more trouble on
        # the code generation with Cython than what it solves
        if self._is_empty():
            raise ValueError('Empty handle to the term structure')

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

    def zero_rate(
            self, Date date, DayCounter day_counter,
            int compounding=Continuous, int frequency=Annual, bool extrapolate=False):
        """ Returns the implied zero-yield rate for the given date.

        The time is calculated as a fraction of year from the reference date.

        Parameters
        ----------
        date: :py:class`~quantlib.time.date.Date'
            The date used to calcule the zero-yield rate.
        day_counter: :py:class`~quantlib.time.daycounter.DayCounter'
            The day counter used to compute the time.
        compounding: int
            The compounding as defined in quantlib.compounding
        frequency: int
            A frequency as defined in quantlib.time.date
        extraplolate: bool, optional
            Default to False
        """
        self._raise_if_empty()

        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()

        cdef _ir.InterestRate ql_zero_rate = term_structure.zeroRate(
            deref(date._thisptr.get()), deref(day_counter._thisptr),
            <_ir.Compounding>compounding, <_ir.Frequency>frequency,
            extrapolate)

        zero_rate = InterestRate(0, None, 0, 0, noalloc=True)
        zero_rate._thisptr = new shared_ptr[_ir.InterestRate](
            new _ir.InterestRate(
                ql_zero_rate.rate(),
                ql_zero_rate.dayCounter(),
                ql_zero_rate.compounding(),
                ql_zero_rate.frequency()
            )
        )

        return zero_rate

    def forward_rate(
            self, Date d1, Date d2, DayCounter day_counter,
            int compounding = Continuous, int frequency=Annual, bool extrapolate=False):
        """ Returns the forward interest rate between two dates or times.

        In the former case, times are calculated as fractions of year from the
        reference date. If both dates (times) are equal the instantaneous
        forward rate is returned.

        Parameters
        ----------
        d1, d2: :py:class`~quantlib.time.date.Date'
            The start and end dates used to calcule the forward rate.
        day_counter: :py:class`~quantlib.time.daycounter.DayCounter'
            The day counter used to compute the time.
        compounding: int
            The compounding as defined in quantlib.compounding
        frequency: int
            A frequency as defined in quantlib.time.date
        extraplolate: bool, optional
            Default to False
        """
        self._raise_if_empty()

        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()

        cdef _ir.InterestRate ql_forward_rate = term_structure.forwardRate(
            deref(d1._thisptr.get()), deref(d2._thisptr.get()),
            deref(day_counter._thisptr), <_ir.Compounding>compounding,
            <_ir.Frequency>frequency, extrapolate)

        forward_rate = InterestRate(0, None, 0, 0, noalloc=True)
        forward_rate._thisptr = new shared_ptr[_ir.InterestRate](
            new _ir.InterestRate(
                ql_forward_rate.rate(),
                ql_forward_rate.dayCounter(),
                ql_forward_rate.compounding(),
                ql_forward_rate.frequency()
            )
        )

        return forward_rate

    def discount(self, value, bool extrapolate=False):
        self._raise_if_empty()

        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()

        cdef double discount_value

        if isinstance(value, Date):
            discount_value = term_structure.discount(
                deref((<Date>value)._thisptr.get()), extrapolate)
        elif isinstance(value, float):
            discount_value = term_structure.discount(
                <Time>value, extrapolate)
        else:
            raise ValueError('Unsupported value type')

        return discount_value

    def time_from_reference(self, Date dt):
        self._raise_if_empty()
        cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
        cdef Time time = term_structure.timeFromReference(deref(dt._thisptr.get()))
        return time

    property reference_date:
        def __get__(self):
            self._raise_if_empty()
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef _yts.Date ref_date = term_structure.referenceDate()
            return date_from_qldate(ref_date)

    property max_date:
        def __get__(self):
            self._raise_if_empty()
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef _yts.Date max_date = term_structure.maxDate()
            return date_from_qldate(max_date)

    property max_time:
        def __get__(self):
            self._raise_if_empty()
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef Time max_time = term_structure.maxTime()
            return max_time

    property day_counter:
        def __get__(self):
            self._raise_if_empty()
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef DayCounter dc = DayCounter()
            dc._thisptr = new _dc.DayCounter(term_structure.dayCounter())
            return dc

    property settlement_days:
        def __get__(self):
            self._raise_if_empty()
            cdef _yts.YieldTermStructure* term_structure = self._get_term_structure()
            cdef int days = term_structure.settlementDays()
            return days

        
