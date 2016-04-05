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

from quantlib import compounding
from quantlib.time import NoFrequency, Once
from quantlib.time.date import frequency_to_str
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

    def __cinit__(self, double rate, DayCounter dc, int compounding, int frequency, **kwargs):

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

            return DayCounter.from_name(dc.name().decode('utf-8'))

    def __repr__(self):
        if self.rate == None:
            return "null interest rate"

        freq_str = frequency_to_str(self.frequency)

        if self.compounding == compounding.Simple:
            cpd_str =  "simple compounding";
        elif self.compounding == compounding.Compounded:
            if self.frequency in [NoFrequency, Once]:
                raise ValueError(
                    "{0} frequency not allowed for this interest rate".format(freq_str)
                )
            else:
                cpd_str =  '{0} compounding'.format(freq_str)
        elif self.compounding == compounding.Continuous:
            cpd_str = "continuous compounding";
        elif self.compounding == compounding.SimpleThenCompounded:
            if self.frequency in [NoFrequency, Once]:
                raise ValueError(
                    "{0} frequency not allowed for this interest rate".format(freq_str)
                )
            else:
                cpd_str = "simple compounding up to {0} months," \
                          "then  {1} compounding".format(12/self.frequency, freq_str)
        else:
            ValueError('unknown compounding convention ({0})'.format(self.compounding))
        return "{0:.2f} {1} {2}".format(
            self.rate,
            self._thisptr.get().dayCounter().name().decode('utf-8'),
            cpd_str
        )
