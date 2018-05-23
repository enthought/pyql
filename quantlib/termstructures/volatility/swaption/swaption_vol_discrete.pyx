from libcpp.vector cimport vector
from cython.operator cimport preincrement as preinc, dereference as deref
from quantlib.time.date cimport period_from_qlperiod, date_from_qldate
cimport quantlib.time._period as _period
cimport quantlib.time._date as _date


cdef inline _svd.SwaptionVolatilityDiscrete* _get_svd(SwaptionVolatilityDiscrete vs):
    return <_svd.SwaptionVolatilityDiscrete*> vs._thisptr.get()

cdef class SwaptionVolatilityDiscrete(SwaptionVolatilityStructure):

    @property
    def option_tenors(self):
        cdef vector[_period.Period].const_iterator it = \
                _get_svd(self).optionTenors().const_begin()
        cdef list r = []
        while it != _get_svd(self).optionTenors().const_end():
            r.append(period_from_qlperiod(deref(it)))
            preinc(it)
        return r

    @property
    def option_dates(self):
        cdef vector[_date.Date].const_iterator it = \
                _get_svd(self).optionDates().const_begin()
        cdef list r = []
        while it != _get_svd(self).optionDates().const_end():
            r.append(date_from_qldate(deref(it)))
            preinc(it)

    @property
    def option_times(self):
        return _get_svd(self).optionTimes()

    @property
    def swap_tenors(self):
        cdef vector[_period.Period].const_iterator it = \
                _get_svd(self).swapTenors().const_begin()
        cdef list r = []
        while it != _get_svd(self).swapTenors().const_end():
            r.append(period_from_qlperiod(deref(it)))
            preinc(it)
        return r

    @property
    def swap_lengths(self):
        return _get_svd(self).swapLengths()
