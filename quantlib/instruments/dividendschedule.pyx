from quantlib.time.date cimport _qldate_from_pydate, _pydate_from_qldate
from quantlib.time._date cimport Date
from quantlib.types cimport Real
from quantlib.cashflows._dividend cimport DividendVector, Dividend

cdef class DividendSchedule:
    def __init__(self, list dividend_dates, vector[Real] dividends):
        cdef vector[Date] c_dividend_dates
        for d in dividend_dates:
            c_dividend_dates.push_back(_qldate_from_pydate(d))
        self.schedule = DividendVector(c_dividend_dates, dividends)

    def __iter__(self):
        cdef shared_ptr[Dividend] div
        for div in self.schedule:
            yield (_pydate_from_qldate(div.get().date()), div.get().amount())
