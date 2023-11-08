include '../types.pxi'

from quantlib.instruments._bond cimport Bond
from quantlib.handle cimport shared_ptr
from quantlib.time._period cimport Frequency
from quantlib.time._date cimport Date
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._daycounter cimport DayCounter

cdef extern from 'ql/cashflows/duration.hpp' namespace 'QuantLib::Duration':
    ctypedef enum Type:
        Simple
        Macaulay
        Modified

cdef extern from 'ql/pricingengines/bond/bondfunctions.hpp' namespace 'QuantLib::BondFunctions':

    cdef Date startDate(Bond bond)

    cdef Time duration(Bond bond,
                    Rate yld,
                    DayCounter dayCounter,
                    int compounding,
                    Frequency frequency,
                    Type dur_type,
                    Date settlementDate ) except +

    cdef Rate bf_yield "QuantLib::BondFunctions::yield" (Bond bond,
                    Real cleanPrice,
                    DayCounter dayCounter,
                    int compounding,
                    Frequency frequency,
                    Date settlementDate,
                    Real accuracy,
                    Size maxIterations,
                    Rate guess) except +

    cdef Real basisPointValue(Bond bond,
                        Rate yld,
                        DayCounter dayCounter,
                        int compounding,
                        Frequency frequency,
                        Date settlementDate) except +

    cdef Spread zSpread(Bond bond,
                Real cleanPrice,
                shared_ptr[YieldTermStructure],
                DayCounter dayCounter,
                int compounding,
                Frequency frequency,
                Date settlementDate,
                Real accuracy,
                Size maxIterations,
                Rate guess) except +
