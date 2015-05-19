include '../types.pxi'

#QL imports
from quantlib.instruments._bonds cimport Bond as QLBond
from quantlib.time._date cimport Day, Month, Year, Date as QLDate
from quantlib.time._period cimport Frequency as _Frequency
from quantlib.time._daycounter cimport DayCounter as _DayCounter
from quantlib._interest_rate cimport InterestRate as _InterestRate
cimport quantlib.termstructures._yield_term_structure as _yt
cimport quantlib.pricingengines._bondfunctions as _bf

#pyql imports
from quantlib.handle cimport shared_ptr, Handle
from cython.operator cimport dereference as deref
from quantlib.interest_rate cimport InterestRate
from quantlib.instruments.bonds cimport Bond
from quantlib.time.date cimport date_from_qldate, Date
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter

cimport quantlib.pricingengines.bondfunctions
cimport quantlib.time._date as _dt

#cdef _bonds.Bond* get_bond(Bond bond):
#    """ Utility function to extract a properly casted Bond pointer out of the
#    internal _thisptr attribute of the Instrument base class. """
#
#    cdef _bonds.Bond* ref = <_bonds.Bond*>bond._thisptr.get()
cdef extern from 'ql/compounding.hpp' namespace 'QuantLib':
    cdef enum Compounding:
        Simple = 0
        Compounded = 1
        Continuous = 2
        SimpleThenCompounded = 3    

cdef extern from 'ql/cashflows/duration.hpp' namespace 'QuantLib':
    ctypedef enum Type "QuantLib::Duration::Type":
        Simple    = 0
        Macaulay  = 1
        Modified  = 2

cdef extern from 'ql/cashflows/duration.hpp' namespace 'QuantLib':
    cdef cppclass Duration:
        Type type

cdef extern from 'ql/pricingengines/bond/bondfunctions.hpp' namespace 'QuantLib':

    cdef _dt.Date _bf_startDate "QuantLib::BondFunctions::startDate" (QLBond)
    cdef Real _bf_duration  "QuantLib::BondFunctions::duration" (QLBond, Real, _DayCounter, int, _Frequency, Type, _dt.Date)
    cdef Rate _bf_yield     "QuantLib::BondFunctions::yield" (QLBond, Real, _DayCounter, int, _Frequency, _dt.Date, Real, Size, Rate)
    cdef Real _bf_bpValue   "QuantLib::BondFunctions::basisPointValue" (QLBond, Real, _DayCounter, int, _Frequency, _dt.Date)    
    cdef Rate _bf_zSpread   "QuantLib::BondFunctions::zSpread" (QLBond, Real, shared_ptr[_yt.YieldTermStructure], _DayCounter, int, _Frequency, _dt.Date, Real, Size, Rate)        
            
cdef class BondFunctions:
    
    def __cinit__(self):
        self._thisptr = new _bf.BondFunctions()

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL


    @classmethod
    def display(self):
        print "hello world"
    
    def startDate(self, Bond bond):
        cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
        d =  _bf_startDate(deref(<QLBond*>_bp))
        return date_from_qldate(d)
      
     
    def duration(self,Bond bond,
                    Rate yld,
                    DayCounter dayCounter,
                    Compounding compounding,
                    int frequency,
                    Type dur_type,
                    Date settlementDate = Date()):
            cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
           
            d =  _bf_duration(
                    deref(<QLBond*>_bp),
                    yld,
                    deref(dayCounter._thisptr),
                    <Compounding> compounding,
                    <_Frequency> frequency,
                    dur_type,
                    deref(settlementDate._thisptr.get()))
            return d
            
    def yld(self,Bond bond,
            Real cleanPrice,
            DayCounter dayCounter,
            int compounding,
            int frequency,
            Date settlementDate,
            Real accuracy,
            Size maxIterations,
            Rate guess):
                
            cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
            cpdef _DayCounter* dc = <_DayCounter*>dayCounter._thisptr
            
            y =  _bf_yield(
                    deref(<QLBond*>_bp),
                    cleanPrice,
                    deref(dc),
                    <Compounding> compounding,
                    <_Frequency> frequency,
                    deref(settlementDate._thisptr.get()),
                    accuracy,
                    maxIterations,
                    guess)                    
            return y
            
                        
    def basisPointValue(self,Bond bond,
            Rate yld,
            DayCounter dayCounter,
            int compounding,
            int frequency,
            Date settlementDate):
            cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
            cpdef _DayCounter* dc = <_DayCounter*>dayCounter._thisptr

            b =  _bf_bpValue(
                    deref(<QLBond*>_bp),
                    yld,
                    deref(dc),
                    <Compounding> compounding,
                    <_Frequency> frequency,
                    deref(settlementDate._thisptr.get()))
            
            return b
            
        
    def zSpread(self, Bond bond, Real cleanPrice,
        YieldTermStructure pyts,
        DayCounter dayCounter,
        int compounding,
        int frequency,
        Date settlementDate,
        Real accuracy,
        Size maxIterations,
        Rate guess):
                        
        cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
        cdef Handle[_yt.YieldTermStructure] yts_handle = deref(pyts._thisptr.get())
        cdef shared_ptr[_yt.YieldTermStructure] _yts = shared_ptr[_yt.YieldTermStructure](yts_handle.currentLink())
        cpdef _DayCounter* dc = <_DayCounter*>dayCounter._thisptr

        d =  self._thisptr.zSpread(
        deref(<QLBond*>_bp),
        cleanPrice,
        _yts,
        deref(dc),
        <Compounding> compounding,
        <_Frequency> frequency,
        deref(settlementDate._thisptr.get()),
        accuracy,
        maxIterations,
        guess)                    
                    
        return d                
