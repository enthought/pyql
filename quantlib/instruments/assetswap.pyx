from cython.operator cimport dereference as deref
from libcpp cimport bool
from quantlib.types cimport Real, Spread
from quantlib.handle cimport shared_ptr, static_pointer_cast
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes cimport _ibor_index as _ib
from quantlib.time.schedule cimport Schedule
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.utilities.null cimport Null
from quantlib.cashflow cimport Leg
from quantlib._cashflow cimport Leg as QlLeg
from . cimport _assetswap as _asw
from .bond cimport Bond
from ._bond cimport Bond as QlBond

cdef class AssetSwap(Swap):
    def __init__(
            self, bool pay_bond_coupon, Bond bond, Real bond_clean_price,
            IborIndex ibor_index, Spread spread, Schedule float_schedule=Schedule.__new__(Schedule),
            DayCounter floating_day_counter=DayCounter(), bool par_asset_swap=True,
            Real gearing=1.0, Real non_par_repayment=Null[Real](), Date deal_maturity=Date()
    ):
        self._thisptr.reset(
            new _asw.AssetSwap(pay_bond_coupon,
                               static_pointer_cast[QlBond](bond._thisptr),
                               bond_clean_price,
                               static_pointer_cast[_ib.IborIndex](ibor_index._thisptr),
                               spread,
                               float_schedule._thisptr,
                               deref(floating_day_counter._thisptr),
                               par_asset_swap,
                               gearing,
                               non_par_repayment,
                               deal_maturity._thisptr
                               )
            )

    @property
    def fair_spread(self):
        return (<_asw.AssetSwap*>self._thisptr.get()).fairSpread()

    @property
    def floating_leg_BPS(self):
        return (<_asw.AssetSwap*>self._thisptr.get()).floatingLegBPS()

    @property
    def floating_leg_NPV(self):
        return (<_asw.AssetSwap*>self._thisptr.get()).floatingLegNPV()

    @property
    def fair_clean_price(self):
        return (<_asw.AssetSwap*>self._thisptr.get()).fairCleanPrice()

    @property
    def fair_non_par_repayment(self):
        return (<_asw.AssetSwap*>self._thisptr.get()).fairNonParRepayment()

    @property
    def bond_leg(self):
        cdef Leg leg = Leg.__new__(Leg)
        leg._thisptr = (<_asw.AssetSwap*>self._thisptr.get()).bondLeg()
        return leg

    @property
    def floating_leg(self):
        cdef Leg leg = Leg.__new__(Leg)
        leg._thisptr = (<_asw.AssetSwap*>self._thisptr.get()).floatingLeg()
        return leg
