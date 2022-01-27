include '../types.pxi'

from quantlib.instruments._bonds cimport Bond as QLBond
from quantlib.time._date cimport Day, Month, Year, Date as QLDate
from quantlib.time._period cimport Frequency
from quantlib.time._daycounter cimport DayCounter as _DayCounter
cimport quantlib.pricingengines._bondfunctions as _bf

from quantlib.handle cimport shared_ptr, Handle
from cython.operator cimport dereference as deref
from quantlib.instruments.bonds cimport Bond
from quantlib.time.date cimport date_from_qldate, Date
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib._compounding cimport Compounding
cimport quantlib.time._date as _dt

cpdef enum DurationType:
    Simple    = 0
    Macaulay  = 1
    Modified  = 2


def startDate(Bond bond):
    cdef QLBond* _bp = <QLBond*>bond._thisptr.get()
    return date_from_qldate(_bf.startDate(deref(_bp)))


def duration(Bond bond not None,
             Rate yld,
             DayCounter dayCounter,
             Compounding compounding,
             Frequency frequency,
             DurationType type,
             Date settlementDate=Date()):
        cdef QLBond* _bp = <QLBond*>bond._thisptr.get()

        return _bf.duration(
            deref(_bp),
            yld,
            deref(dayCounter._thisptr),
            compounding,
            frequency,
            <_bf.Type>type,
            deref(settlementDate._thisptr))


def bond_yield(Bond bond not None,
               Real cleanPrice,
               DayCounter dayCounter not None,
               Compounding compounding,
               Frequency frequency,
               Date settlementDate not None,
               Real accuracy,
               Size maxIterations,
               Rate guess):

        cdef QLBond* _bp = <QLBond*>bond._thisptr.get()

        return _bf.bf_yield(
            deref(_bp),
            cleanPrice,
            deref(dayCounter._thisptr),
            compounding,
            frequency,
            deref(settlementDate._thisptr),
            accuracy,
            maxIterations,
            guess)


def basisPointValue(Bond bond not None,
                    Rate yld,
                    DayCounter dayCounter not None,
                    Compounding compounding,
                    Frequency frequency,
                    Date settlementDate not None):
        cdef QLBond* _bp = <QLBond*>bond._thisptr.get()

        return _bf.basisPointValue(
            deref(_bp),
            yld,
            deref(dayCounter._thisptr),
            compounding,
            frequency,
            deref(settlementDate._thisptr))


def zSpread(Bond bond, Real cleanPrice,
            YieldTermStructure yts not None,
            DayCounter dayCounter not None,
            Compounding compounding,
            Frequency frequency,
            Date settlementDate not None,
            Real accuracy,
            Size maxIterations,
            Rate guess):

    cdef QLBond* _bp = <QLBond*>bond._thisptr.get()

    return _bf.zSpread(
        deref(_bp),
        cleanPrice,
        yts.as_shared_ptr(),
        deref(dayCounter._thisptr),
        compounding,
        frequency,
        deref(settlementDate._thisptr),
        accuracy,
        maxIterations,
        guess)
