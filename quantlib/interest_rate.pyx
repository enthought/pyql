"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include 'types.pxi'

from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr
cimport _interest_rate as _ir

from quantlib.time.daycounter cimport DayCounter

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

    def __cinit__(self, float rate, DayCounter dc, int compounding, int frequency, **kwargs):

        if 'noalloc' in kwargs:
            return
            
        self._thisptr = new shared_ptr[_ir.InterestRate](
            new _ir.InterestRate(
                <Rate>rate, deref(dc._thisptr), <_ir.Compounding>compounding,
                <_ir.Frequency>frequency
            )
        )


    property rate:
        def __get__(self):
            return self._thisptr.get().rate()

    property compounding:
        def __get__(self):
            return self._thisptr.get().compounding()

    property frequency:
        """ Returns the frequency used for computation.

        If the Frequency does not make sense, it returns NoFrequency.
        Frequency only make sense when compounding is Compounded or
        SingleThenCompounded.

        """
        def __get__(self):
            return self._thisptr.get().frequency()


    property day_counter:
        def __get__(self):
            cdef _ir.DayCounter dc = self._thisptr.get().dayCounter()

            return DayCounter.from_name(dc.name().c_str())

