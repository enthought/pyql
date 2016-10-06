include '../types.pxi'

from quantlib.instruments._bonds cimport Bond as QLBond
from quantlib.time._date cimport Day, Month, Year, Date as QLDate
from quantlib.time._period cimport Frequency as _Frequency
from quantlib.time._daycounter cimport DayCounter as _DayCounter
cimport quantlib.termstructures._yield_term_structure as _yt
cimport quantlib.pricingengines._bondfunctions as _bf

from quantlib.handle cimport shared_ptr, Handle
from cython.operator cimport dereference as deref
from quantlib.instruments.bonds cimport Bond
from quantlib.time.date cimport date_from_qldate, Date
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter

cimport quantlib.time._date as _dt

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
    cdef Rate _bf_yield     "QuantLib::BondFunctions::yield" (QLBond, Real, _DayCounter, int, _Frequency, _dt.Date, Real, Size, Rate)


def startDate(Bond bond):
    cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
    d =  _bf.startDate(deref(<QLBond*>_bp))
    return date_from_qldate(d)


def duration(Bond bond,
                Rate yld,
                DayCounter dayCounter,
                Compounding compounding,
                int frequency,
                Type dur_type,
                Date settlementDate = Date()):
        cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()

        d =  _bf.duration(
                deref(<QLBond*>_bp),
                yld,
                deref(dayCounter._thisptr),
                <Compounding> compounding,
                <_Frequency> frequency,
                dur_type,
                deref(settlementDate._thisptr.get()))
        return d

def yld(Bond bond,
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


def basisPointValue(Bond bond,
        Rate yld,
        DayCounter dayCounter,
        int compounding,
        int frequency,
        Date settlementDate):
        cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
        cpdef _DayCounter* dc = <_DayCounter*>dayCounter._thisptr

        b =  _bf.basisPointValue(
                deref(<QLBond*>_bp),
                yld,
                deref(dc),
                <Compounding> compounding,
                <_Frequency> frequency,
                deref(settlementDate._thisptr.get()))

        return b


def zSpread(Bond bond, Real cleanPrice,
    YieldTermStructure pyts,
    DayCounter dayCounter,
    int compounding,
    int frequency,
    Date settlementDate,
    Real accuracy,
    Size maxIterations,
    Rate guess):

    cpdef QLBond* _bp = <QLBond*>bond._thisptr.get()
    cdef shared_ptr[_yt.YieldTermStructure] _yts = pyts._thisptr.currentLink()
    cpdef _DayCounter* dc = <_DayCounter*>dayCounter._thisptr

    d =  _bf.zSpread(
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
