include '../types.pxi'

from quantlib.instruments._bonds cimport Bond as QLBond
from quantlib.handle cimport shared_ptr
from quantlib.time._period cimport Frequency
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.time._daycounter cimport DayCounter

cimport quantlib.time._date as _dt

cdef extern from 'ql/cashflows/duration.hpp' namespace 'QuantLib':
    ctypedef enum Type "QuantLib::Duration::Type":
        Simple    "QuantLib::Duration::Simple"
        Macaulay  "QuantLib::Duration::Macaulay"
        Modified  "QuantLib::Duration::Modified"

cdef extern from 'ql/cashflows/duration.hpp' namespace 'QuantLib':
    cdef cppclass Duration:
        Type type

cdef extern from 'ql/pricingengines/bond/bondfunctions.hpp' namespace 'QuantLib':
    cdef Rate bf_yield "BondFunctions::yield" (QLBond, Real, DayCounter, int, Frequency, _dt.Date, Real, Size, Rate)

cdef extern from 'ql/pricingengines/bond/bondfunctions.hpp' namespace 'QuantLib::BondFunctions':

    cdef _dt.Date startDate(QLBond bond)
    
    cdef Time duration(QLBond bond, 
                    Rate yld,
                    DayCounter dayCounter,
                    int compounding,
                    Frequency frequency,
                    Type dur_type,
                    _dt.Date settlementDate ) except +   
                  
    cdef Rate bf_yield(QLBond bond,
                    Real cleanPrice,
                    DayCounter dayCounter,
                    int compounding,
                    Frequency frequency,
                    _dt.Date settlementDate,
                    Real accuracy,
                    Size maxIterations,
                    Rate guess) except +
                    
    cdef Real basisPointValue(QLBond bond,
                        Rate yld,
                        DayCounter dayCounter,
                        int compounding,
                        Frequency frequency,
                        _dt.Date settlementDate) except +      
                  
    cdef Spread zSpread(QLBond bond,
                Real cleanPrice,
                shared_ptr[YieldTermStructure],
                DayCounter dayCounter,
                int compounding,
                Frequency frequency,
                _dt.Date settlementDate,
                Real accuracy,
                Size maxIterations,
                Rate guess) except +