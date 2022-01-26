from quantlib.types cimport Real
from cython.operator cimport dereference as deref
from quantlib.handle cimport static_pointer_cast
from quantlib.cashflows.rateaveraging cimport RateAveraging
from quantlib.time.frequency cimport Frequency
from quantlib.quote cimport Quote
from quantlib.time.date cimport Date
from quantlib.time._date cimport Month, Year
from quantlib.indexes.ibor_index cimport OvernightIndex
cimport quantlib.indexes._ibor_index as _ii
from . cimport _overnightindexfutureratehelper as _oifrh

cdef class OvernightIndexFutureRateHelper(RateHelper):
    """ Future on a compounded overnight index investment.

    Compatible with SOFR futures and Sonia futures available on
    CME and ICE exchanges.
    """
    def __init__(self, Quote price, Date value_date, Date maturity_date, OvernightIndex overnight_index, Quote convexity_adjustment, RateAveraging averaging_method):
        self._thisptr.reset(
            new _oifrh.OvernightIndexFutureRateHelper(
                price.handle(),
                deref(value_date._thisptr),
                deref(maturity_date._thisptr),
                static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                convexity_adjustment.handle(),
                averaging_method
            )
        )

cdef class SofrFutureRateHelper(OvernightIndexFutureRateHelper):
    def __init__(self, price, Month reference_month, Year reference_year, Frequency reference_freq, OvernightIndex overnight_index, convexity_adjustment, RateAveraging averaging_method):
        if isinstance(price, float) and isinstance(convexity_adjustment, float):
            self._thisptr.reset(
                new _oifrh.SofrFutureRateHelper(
                    <Real>price,
                    reference_month,
                    reference_year,
                    reference_freq,
                    static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                    <Real>convexity_adjustment,
                    averaging_method
                )
            )
        elif isinstance(price, Quote) and isinstance(convexity_adjustment, Quote):
            self._thisptr.reset(
                new _oifrh.SofrFutureRateHelper(
                    (<Quote>price).handle(),
                    reference_month,
                    reference_year,
                    reference_freq,
                    static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                    (<Quote>convexity_adjustment).handle(),
                    averaging_method
                )
            )
