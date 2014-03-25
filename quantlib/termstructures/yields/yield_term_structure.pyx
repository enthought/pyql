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
cimport quantlib._interest_rate as _ir

from quantlib.quotes cimport Quote
from quantlib.interest_rate cimport InterestRate

cdef class YieldTermStructure:

    # FIXME: the relinkable stuff is really ugly. Do we need this on the
    # python side?

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
            # Create a new RelinkableHandle to a YieldTermStructure within a
            # new shared_ptr
            self._relinkable_ptr = new \
                shared_ptr[ffwd.RelinkableHandle[ffwd.YieldTermStructure]](
                    new ffwd.RelinkableHandle[ffwd.YieldTermStructure]()
                )
        else:
            # initialize an empty shared_ptr. ! Might be dangerous
            self._thisptr = new shared_ptr[ffwd.YieldTermStructure]()

    def link_to(self, YieldTermStructure structure):
        if not self.relinkable:
            raise ValueError('Non relinkable term structure !')
        else:
            self._relinkable_ptr.get().linkTo(deref(structure._thisptr))

        return

    def zero_rate(
            self, Date date, DayCounter day_counter,
            int compounding, int frequency=Annual, extrapolate=False):
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
        cdef ffwd.YieldTermStructure* term_structure
        if self.relinkable is True:
            # retrieves the shared_ptr (currentLink()) then gets the
            # term_structure (get())
            # FIXME: this does not compile :
            # term_structure = self._relinkable_ptr.get().currentLink().get()
            raise NotImplementedError(
                "Cannot compute zero_rate on relinkable term structure."
            )
        else:
            term_structure = self._thisptr.get()

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
            int compounding, int frequency=Annual, extrapolate=False):
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
        cdef ffwd.YieldTermStructure* term_structure
        if self.relinkable is True:
            # retrieves the shared_ptr (currentLink()) then gets the
            # term_structure (get())
            # FIXME: this does not compile :
            # term_structure = self._relinkable_ptr.get().currentLink().get()
            raise NotImplementedError(
                "Cannot compute forward_rate on relinkable term structure."
            )
        else:
            term_structure = self._thisptr.get()

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

    def discount(self, value):
        cdef ffwd.YieldTermStructure* term_structure
        cdef shared_ptr[ffwd.YieldTermStructure] ts_ptr
        if self.relinkable is True:
            # retrieves the shared_ptr (currentLink()) then gets the
            # term_structure (get())
            ts_ptr = shared_ptr[ffwd.YieldTermStructure](
                self._relinkable_ptr.get().currentLink())
            term_structure = ts_ptr.get()
        else:
            term_structure = self._thisptr.get()

        if isinstance(value, Date):
            discount_value = term_structure.discount(
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

    property max_date:
        def __get__(self):
            cdef ffwd.Date max_date = self._thisptr.get().maxDate()
            return date_from_qldate(max_date)
