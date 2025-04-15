from quantlib.time.date cimport Date
from cython.operator cimport dereference as deref
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.types cimport Natural, Real
from quantlib.handle cimport static_pointer_cast
from quantlib.position cimport Position
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _bondforward as _bf
from . cimport _bond
from .bond cimport Bond

cdef class BondForward(Forward):
    r"""Forward contract on a bond

    value_date
        refers to the settlement date of the bond forward contract.
    maturity_date
        this is the delivery (or repurchase date) for the underlying bond
          (not the bond's maturity date).

    Notes
    -----
    Relevant formulas used in the calculations (:math:`P` refers to a price): pomme

    #. Clearn forward price:

       .. math::
          P_{\text{CleanFwd}}(t) = P_{\text{DirtyFwd}}(t) - AI(t=\text{deliveryDate})

       where :math:`AI` refers to the accrued interest on the underlying bond.

    #. Dirty forward price:

       .. math::
          P_{\text{DirtyFwd}}(t) = \frac{P_{DirtySpot}(t) - \text{SpotIncome}(t)}{\text{discountCurve}\rightarrow \text{discount}(t=\text{deliveryDate})}

    #. Spot income:

       .. math::
          SpotIncome(t) = \sum_i \left( CF_i \times \text{incomeDiscountCurve}\rightarrow \text{discount}(t_i) \right)

       where :math:`CF_i` represents the ith bond cash flow (coupon payment)
       associated with the underlying bond falling between the
       `settlementDate` and the `deliveryDate`.

    (Note the two different discount curves used in 1. and 2.)
"""
    def __init__(self, Date value_date, Date maturity_date, Position position_type, Real strike, Natural settlement_days,
                 DayCounter day_counter, Calendar calendar, BusinessDayConvention convention, Bond bond,
                 HandleYieldTermStructure discount_curve, HandleYieldTermStructure income_discount_curve):
        self._thisptr.reset(
            new _bf.BondForward(value_date._thisptr, maturity_date._thisptr, position_type, strike,
                                settlement_days, deref(day_counter._thisptr), calendar._thisptr, convention,
                                static_pointer_cast[_bond.Bond](bond._thisptr), discount_curve.handle, income_discount_curve.handle)
            )

    @property
    def forward_price(self):
        """(dirty) forward bond price"""
        return (<_bf.BondForward*>self._thisptr.get()).forwardPrice()

    @property
    def clean_forward_price(self):
        """(dirty) forward bond price minus accrued on bond at delivery"""
        return (<_bf.BondForward*>self._thisptr.get()).cleanForwardPrice()
