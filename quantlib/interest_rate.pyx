# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

include 'types.pxi'

from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr

from quantlib.time.daycounter cimport DayCounter
cimport quantlib.time._daycounter as _daycounter
from quantlib._compounding cimport Compounding
from quantlib.time.frequency cimport Frequency

cdef class InterestRate:
    """ This class encapsulate the interest rate compounding algebra.

    It manages day-counting conventions, compounding conventions,
    conversion between different conventions, discount/compound factor
    calculations, and implied/equivalent rate calculations.

    """

    def __init__(self, double rate, DayCounter dc not None, Compounding compounding,
                 int frequency):

        self._thisptr = _ir.InterestRate(
            <Rate>rate, deref(dc._thisptr), compounding,
            <_ir.Frequency>frequency
        )


    property rate:
        def __get__(self):
            return self._thisptr.rate()

    property compounding:
        def __get__(self):
            return self._thisptr.compounding()

    def __float__(self):
        return self._thisptr.rate()

    property frequency:
        """ Returns the frequency used for computation.

        If the Frequency does not make sense, it returns NoFrequency.
        Frequency only make sense when compounding is Compounded or
        SimpleThenCompounded.

        """
        def __get__(self):
            return self._thisptr.frequency()


    property day_counter:
        def __get__(self):
            cdef DayCounter dc = DayCounter.__new__(DayCounter)
            dc._thisptr = new _daycounter.DayCounter(self._thisptr.dayCounter())
            return dc

    def __repr__(self):
        cdef _ir.stringstream ss
        ss << self._thisptr
        return ss.str().decode()

    def compound_factor(self, Time t):
        return self._thisptr.compoundFactor(t)

    def implied_rate(self, Real compound,
                     DayCounter result_dc not None,
                     Compounding comp,
                     Frequency freq,
                     Time t):
        cdef InterestRate r = InterestRate.__new__(InterestRate)
        r._thisptr = self._thisptr.impliedRate(compound,
                                               deref(result_dc._thisptr),
                                               comp,
                                               freq,
                                               t)
        return r

    def equivalent_rate(self, Compounding comp,
                        Frequency freq,
                        Time t):
        cdef InterestRate r = InterestRate.__new__(InterestRate)
        r._thisptr = self._thisptr.equivalentRate(comp, freq, t)
        return r
