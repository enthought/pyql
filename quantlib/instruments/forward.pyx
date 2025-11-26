from cython.operator cimport dereference as deref
from quantlib.types cimport Real
from quantlib.compounding cimport Compounding
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.handle cimport HandleYieldTermStructure
from quantlib.interest_rate cimport InterestRate
from libcpp.utility cimport move
from quantlib cimport _interest_rate as _ir
from . cimport _forward

cdef class Forward(Instrument):
    """Abstract base forward class."""

    @property
    def spot_value(self):
        """The spot value/price of the underlying financial instrument."""
        return (<_forward.Forward*>self._thisptr.get()).spotValue()

    @property
    def forward_value(self):
        """The forward value/price of the underlying, discounting income/dividends."""
        return (<_forward.Forward*>self._thisptr.get()).forwardValue()

    def spot_income(self, HandleYieldTermStructure income_discount_curve):
        """The NPV of income/dividends/storage-costs etc. of the underlying instrument.

        Parameters
        ----------
        income_discount_curve : :class:`~quantlib.termstructures.yield_term_structure.HandleYieldTermStructure`
            The yield term structure handle for discounting the income.
        """
        return  (<_forward.Forward*>self._thisptr.get()).spotIncome(income_discount_curve.handle())

    def implied_yield(self, Real underlying_spot_value, Real forward_value, Date settlement_date, Compounding convention, DayCounter day_counter):
        """Calculates the implied yield of the forward contract.

        This is a simple yield calculation based on underlying spot and forward
        values, taking into account underlying income.

        Parameters
        ----------
        underlying_spot_value : float
            The spot value of the underlying.
        forward_value : float
            The forward value.
        settlement_date : :class:`~quantlib.time.date.Date`
            The settlement date.
        convention : :class:`~quantlib.compounding.Compounding`
            The compounding convention.
        day_counter : :class:`~quantlib.time.daycounter.DayCounter`
            The day counter.
        """
        cdef InterestRate ir = InterestRate.__new__(InterestRate)
        ir._thisptr = move[_ir.InterestRate](
            (<_forward.Forward*>self._thisptr.get()).impliedYield(underlying_spot_value, forward_value, settlement_date._thisptr, convention, deref(day_counter._thisptr)))
