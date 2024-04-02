include '../types.pxi'

from quantlib.time._date cimport Day, Month, Year, Date as QLDate
from quantlib.time._period cimport Frequency
from quantlib.time._daycounter cimport DayCounter as _DayCounter
cimport quantlib.pricingengines._bondfunctions as _bf

from quantlib.handle cimport shared_ptr, Handle
from cython.operator cimport dereference as deref
from quantlib.instruments.bond cimport Bond
from quantlib.time.date cimport date_from_qldate, Date
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib.compounding cimport Compounding
cimport quantlib.time._date as _dt

cpdef enum DurationType:
    Simple    = 0
    Macaulay  = 1
    Modified  = 2


def startDate(Bond bond):
    return date_from_qldate(_bf.startDate(deref(bond.as_ptr())))


def duration(Bond bond not None,
             Rate yld,
             DayCounter dayCounter,
             Compounding compounding,
             Frequency frequency,
             DurationType type,
             Date settlementDate=Date()):
        return _bf.duration(
            deref(bond.as_ptr()),
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
               Date settlementDate=Date(),
               Real accuracy=1e-10,
               Size maxIterations=100,
               Rate guess=0.05):

        return _bf.bf_yield(
            deref(bond.as_ptr()),
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
                    Date settlementDate=Date()):
        return _bf.basisPointValue(
            deref(bond.as_ptr()),
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
            Date settlementDate=Date(),
            Real accuracy=1e-10,
            Size maxIterations=100,
            Rate guess=0):

    return _bf.zSpread(
        deref(bond.as_ptr()),
        cleanPrice,
        yts.as_shared_ptr(),
        deref(dayCounter._thisptr),
        compounding,
        frequency,
        deref(settlementDate._thisptr),
        accuracy,
        maxIterations,
        guess)
