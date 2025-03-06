# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
from quantlib.types cimport Rate, Real, Time
from cython.operator cimport dereference as deref

from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
cimport quantlib.time._daycounter as _daycounter
from quantlib.compounding cimport Compounding
from quantlib.time.frequency cimport Frequency

cdef class InterestRate:
    """ This class encapsulate the interest rate compounding algebra.

    It manages day-counting conventions, compounding conventions,
    conversion between different conventions, discount/compound factor
    calculations, and implied/equivalent rate calculations.

    """

    def __init__(self, Rate rate, DayCounter dc not None, Compounding compounding,
                 Frequency frequency):

        self._thisptr = _ir.InterestRate(
            rate, deref(dc._thisptr), compounding, frequency
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

    def compound_factor(self, Date d1, Date d2, Date ref_start=Date(), Date ref_end=Date()):
        return self._thisptr.compoundFactor(d1._thisptr, d2._thisptr, ref_start._thisptr, ref_end._thisptr)

    def discount_factor(self, Date d1, Date d2, Date ref_start=Date(), Date ref_end=Date()):
        return self._thisptr.discountFactor(d1._thisptr, d2._thisptr, ref_start._thisptr, ref_end._thisptr)

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
