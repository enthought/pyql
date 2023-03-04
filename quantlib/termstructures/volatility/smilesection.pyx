include "../../types.pxi"

cimport quantlib.time._daycounter as _dc
from quantlib.time.date cimport date_from_qldate
from quantlib.time.daycounter cimport DayCounter
from quantlib.instruments.option cimport OptionType

cdef class SmileSection:
    @property
    def min_strike(self):
        return self._thisptr.get().minStrike()

    @property
    def max_strike(self):
        return self._thisptr.get().maxStrike()

    @property
    def exercise_time(self):
        return self._thisptr.get().exerciseTime()

    @property
    def exercise_date(self):
        return date_from_qldate(self._thisptr.get().exerciseDate())

    @property
    def day_counter(self):
        cdef DayCounter dc = DayCounter.__new__(DayCounter)
        dc._thisptr = new _dc.DayCounter(self._thisptr.get().dayCounter())
        return dc

    @property
    def reference_date(self):
        return date_from_qldate(self._thisptr.get().referenceDate())

    def option_price(self, Rate strike, OptionType option_type, Real discount=1.):
        return self._thisptr.get().optionPrice(strike, option_type, discount)

    def volatility(self, Rate strike):
        return self._thisptr.get().volatility(strike)

    def vega(self, Rate strike, Real discount=1.):
        return self._thisptr.get().vega(strike, discount)

    def density(self, Rate strike, Real discount=1., Real gap=1e-4):
        return self._thisptr.get().density(strike, discount, gap)
