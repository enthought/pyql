from quantlib.handle cimport Handle
from quantlib.ext cimport shared_ptr
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib._cashflow cimport Leg
cdef extern from 'ql/cashflows/inflationcouponpricer.hpp' namespace 'QuantLib':
    cdef cppclass InflationCouponPricer:
        pass

    void setCouponPricer(const Leg& leg,
                         const shared_ptr[InflationCouponPricer]&)

    cdef cppclass YoYInflationCouponPricer(InflationCouponPricer):
        YoYInflationCouponPricer(
            const Handle[YieldTermStructure]& nominalTermStructure) except +
