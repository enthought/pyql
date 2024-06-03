from libcpp.vector cimport vector
from cython.operator cimport dereference as deref, preincrement as preinc
from quantlib._cashflow cimport Leg
from quantlib.cashflow cimport CashFlow
from quantlib.cashflows.duration cimport Duration
from quantlib.types cimport Rate, Real, Size
from quantlib.time.frequency cimport Frequency
from . cimport _bondfunctions as _bf

from quantlib.handle cimport static_pointer_cast
from cython.operator cimport dereference as deref
from quantlib.instruments.bond cimport Bond, Price
from quantlib.time.date cimport date_from_qldate, Date
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.termstructures.yield_term_structure cimport YieldTermStructure
from quantlib.time.daycounter cimport DayCounter
from quantlib.compounding cimport Compounding

def start_date(Bond bond):
    return date_from_qldate(_bf.startDate(deref(bond.as_ptr())))

def previous_cash_flow(Bond bond, Date ref_date=Date()):
    cdef Leg.const_reverse_iterator it  = _bf.previousCashFlow(deref(bond.as_ptr()), ref_date._thisptr)
    cdef CashFlow cf = CashFlow.__new__(CashFlow)
    while it != bond.as_ptr().cashflows().const_rbegin():
        cf._thisptr = deref(it)
        yield cf
        preinc(it)


def duration(Bond bond not None,
             Rate yld,
             DayCounter day_counter,
             Compounding compounding,
             Frequency frequency,
             Duration type = Duration.Modified,
             Date settlement_date=Date()):
        return _bf.duration(
            deref(bond.as_ptr()),
            yld,
            deref(day_counter._thisptr),
            compounding,
            frequency,
            type,
            settlement_date._thisptr)

def convexity(Bond bond not None,
              Rate yld,
              DayCounter day_counter,
              Compounding compounding,
              Frequency frequency,
              Date settlement_date=Date()):
    return _bf.convexity(
        deref(bond.as_ptr()),
        yld,
        deref(day_counter._thisptr),
        compounding,
        frequency,
        settlement_date._thisptr)

def bond_yield(Bond bond not None,
               Price price,
               DayCounter day_counter not None,
               Compounding compounding,
               Frequency frequency,
               Date settlement_date=Date(),
               Real accuracy=1e-10,
               Size max_iterations=100,
               Rate guess=0.05):

        return _bf.bf_yield(
            deref(bond.as_ptr()),
            price._this,
            deref(day_counter._thisptr),
            compounding,
            frequency,
            settlement_date._thisptr,
            accuracy,
            max_iterations,
            guess)

def clean_price(Bond bond not None,
                Rate y,
                DayCounter day_counter,
                Compounding compounding,
                Frequency frequency,
                Date settlement_date=Date()):
    return _bf.cleanPrice(deref(bond.as_ptr()),
                          y,
                          deref(day_counter._thisptr),
                          compounding,
                          frequency,
                          settlement_date._thisptr)

def basisPointValue(Bond bond not None,
                    Rate yld,
                    DayCounter day_counter not None,
                    Compounding compounding,
                    Frequency frequency,
                    Date settlement_date=Date()):
        return _bf.basisPointValue(
            deref(bond.as_ptr()),
            yld,
            deref(day_counter._thisptr),
            compounding,
            frequency,
            settlement_date._thisptr)


def zSpread(Bond bond, Price price,
            YieldTermStructure yts not None,
            DayCounter day_counter not None,
            Compounding compounding,
            Frequency frequency,
            Date settlement_date=Date(),
            Real accuracy=1e-10,
            Size max_iterations=100,
            Rate guess=0.0):

    return _bf.zSpread(
        deref(bond.as_ptr()),
        price._this,
        static_pointer_cast[_yts.YieldTermStructure](yts._thisptr),
        deref(day_counter._thisptr),
        compounding,
        frequency,
        settlement_date._thisptr,
        accuracy,
        max_iterations,
        guess)
