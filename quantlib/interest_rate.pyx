# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include 'types.pxi'

from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr
cimport _interest_rate as _ir

from quantlib.time.date import frequency_to_str
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.time._daycounter as _daycounter
from quantlib._compounding cimport Compounding

cdef class InterestRate:
    """ This class encapsulate the interest rate compounding algebra.

    It manages day-counting conventions, compounding conventions,
    conversion between different conventions, discount/compound factor
    calculations, and implied/equivalent rate calculations.

    """

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __init__(self, double rate, DayCounter dc not None, Compounding compounding,
                 int frequency):

        self._thisptr = new shared_ptr[_ir.InterestRate](
            new _ir.InterestRate(
                <Rate>rate, deref(dc._thisptr), compounding,
                <_ir.Frequency>frequency
            )
        )


    property rate:
        def __get__(self):
            return self._thisptr.get().rate()

    property compounding:
        def __get__(self):
            return self._thisptr.get().compounding()

    def __float__(self):
        return self._thisptr.get().rate()

    property frequency:
        """ Returns the frequency used for computation.

        If the Frequency does not make sense, it returns NoFrequency.
        Frequency only make sense when compounding is Compounded or
        SimpleThenCompounded.

        """
        def __get__(self):
            return self._thisptr.get().frequency()


    property day_counter:
        def __get__(self):
            cdef DayCounter dc = DayCounter.__new__(DayCounter)
            dc._thisptr = new _daycounter.DayCounter(self._thisptr.get().dayCounter())
            return dc

    def __repr__(self):
        cdef _ir.stringstream ss
        ss << deref(self._thisptr.get())
        return ss.str().decode()
