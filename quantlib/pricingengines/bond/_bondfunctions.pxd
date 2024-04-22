from quantlib.types cimport Rate, Real, Spread, Size, Time

from quantlib.instruments._bond cimport Bond
from quantlib.handle cimport shared_ptr
from quantlib.time._period cimport Frequency
from quantlib.time._date cimport Date
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._daycounter cimport DayCounter
from quantlib.compounding cimport Compounding
from quantlib._cashflow cimport Leg
from quantlib.cashflows.duration cimport Duration

cdef extern from 'ql/pricingengines/bond/bondfunctions.hpp' namespace 'QuantLib::BondFunctions' nogil:

    cdef Date startDate(Bond bond)
    cdef Leg.const_reverse_iterator previousCashFlow(const Bond& bond,
                                                     Date refDate) # = Date()
    cdef Time duration(Bond bond,
                    Rate yld,
                    DayCounter dayCounter,
                       Compounding compounding,
                    Frequency frequency,
                    Duration dur_type, #Duration.Modified
                    Date settlementDate ) except + # Date()

    cdef Rate bf_yield "QuantLib::BondFunctions::yield" (Bond bond,
                    Bond.Price Price,
                    DayCounter dayCounter,
                    Compounding compounding,
                    Frequency frequency,
                    Date settlementDate,
                    Real accuracy,
                    Size maxIterations,
                    Rate guess) except +

    cdef Real cleanPrice(Bond bond,
                         Rate yld,
                         DayCounter dayCounter,
                         Compounding compounding,
                         Frequency frequency,
                         Date settlementDate) except +

    cdef Real basisPointValue(Bond bond,
                        Rate yld,
                        DayCounter dayCounter,
                        Compounding compounding,
                        Frequency frequency,
                        Date settlementDate) except +

    cdef Real convexity(Bond bond,
                        Rate yld,
                        DayCounter dayCounter,
                        Compounding compounding,
                        Frequency frequency,
                        Date settlementDate) except +


    cdef Spread zSpread(Bond bond,
                        Bond.Price Price,
                shared_ptr[YieldTermStructure],
                DayCounter dayCounter,
                Compounding compounding,
                Frequency frequency,
                Date settlementDate,
                Real accuracy,
                Size maxIterations,
                Rate guess) except +
