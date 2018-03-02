include '../../../types.pxi'
from libcpp cimport bool
from cython.operator cimport dereference as deref
from quantlib.time.date cimport Date, Period

cdef class SwaptionVolatilityStructure:

    def volatility(self, option_date, swap_date, Rate strike,
                   bool extrapolate=False):
        if isinstance(swap_date, Period):
            if isinstance(option_date, Period):
                return self._thisptr.get().volatility(
                    deref((<Period>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            elif isinstance(option_date, Date):
                return self._thisptr.get().volatility(
                    deref((<Date>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            elif isinstance(option_date, float):
                return self._thisptr.get().volatility(
                    <Time>option_date,
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        elif isinstance(swap_date, float):
            if isinstance(option_date, Period):
                return self._thisptr.get().volatility(
                    deref((<Period>option_date)._thisptr),
                    <Time>swap_date,
                    strike,
                    extrapolate)
            elif isinstance(option_date, Date):
                return self._thisptr.get().volatility(
                    deref((<Date>option_date)._thisptr),
                    <Time>swap_date,
                    strike,
                    extrapolate)
            elif isinstance(option_date, float):
                return self._thisptr.get().volatility(
                    <Time>option_date,
                    <Time>swap_date,
                    strike,
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        else:
            raise TypeError('swap_date needs to be a Period or a Time')
