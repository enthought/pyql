from cython.operator cimport dereference as deref
from quantlib.types cimport Real
from quantlib.compounding cimport Compounding
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from quantlib.interest_rate cimport InterestRate
from libcpp.utility cimport move
from quantlib cimport _interest_rate as _ir
from . cimport _forward

cdef class Forward(Instrument):

    @property
    def spot_value(self):
        """spot value/price of an underlying financial instrument"""
        return (<_forward.Forward*>self._thisptr.get()).spotValue()

    @property
    def forward_value(self):
        """forward value/price of underlying, discounting income/dividends"""
        return (<_forward.Forward*>self._thisptr.get()).forwardValue()

    def spot_income(self, HandleYieldTermStructure income_discount_curve):
        """NPV of income/dividends/storate-cossts etc. of underlying instrument"""
        return  (<_forward.Forward*>self._thisptr.get()).spotIncome(income_discount_curve.handle)


    def implied_yield(self, Real underlying_spot_value, Real forward_value, Date settlement_date, Compounding convention, DayCounter day_counter):
        """implied yield

        Simple yield calculation based on underlying spot and forward values, taking into account underlying income."""
        cdef InterestRate ir = InterestRate.__new__(InterestRate)
        ir._thisptr = move[_ir.InterestRate](
            (<_forward.Forward*>self._thisptr.get()).impliedYield(underlying_spot_value, forward_value, settlement_date._thisptr, convention, deref(day_counter._thisptr)))
