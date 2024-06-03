from quantlib.types cimport Natural
from cython.operator cimport dereference as deref
from libcpp cimport bool
from quantlib.handle cimport static_pointer_cast
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time.date cimport Period
from quantlib.time.calendar cimport Calendar
from quantlib.indexes.ibor_index cimport IborIndex
from quantlib.indexes cimport _ibor_index as _ii
from quantlib.quote cimport Quote
from quantlib.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _crosscurrencyratehelpers as _ccyrh

cdef class ConstNotionalCrossCurrencyBasisSwapRateHelper(RelativeDateRateHelper):
    """ Rate helper for bootstrapping over constant-notional cross-currency basis swaps

    Unlike marked-to-market cross currency swaps, both notionals
    expressed in base and quote currency remain constant throughout
    the lifetime of the swap.
    Note on used conventions. Consider a currency pair EUR-USD.
    EUR is the base currency, while USD is the quote currency.
    The quote currency indicates the amount to be paid in that
    currency for one unit of base currency.
    Hence, for a cross currency swap we define a base currency
    leg and a quote currency leg. The parameters of the instrument,
    e.g. collateral currency, basis, resetting  or constant notional
    legs are defined relative to what base and quote currencies are.
    For example, in case of EUR-USD basis swaps the collateral is paid
    in quote currency (USD), the basis is given on the base currency
    leg (EUR), etc.

    For more details see:
    N. Moreni, A. Pallavicini (2015)
    FX Modelling in Collateralized Markets: foreign measures, basis curves
    and pricing formulae.
    """

    def __init__(self, Quote basis, Period tenor, Natural fixing_days, Calendar calendar,
                 BusinessDayConvention convention, bool end_of_month, IborIndex base_currency_index,
                 IborIndex quote_currency_index, HandleYieldTermStructure collateral_curve,
                 bool is_fx_base_currency_collateral_currency,
                 bool is_basis_on_fx_base_currency_leg):
        self._thisptr.reset(
            new _ccyrh.ConstNotionalCrossCurrencyBasisSwapRateHelper(
                basis.handle(),
                deref(tenor._thisptr),
                fixing_days,
                calendar._thisptr,
                convention,
                end_of_month,
                static_pointer_cast[_ii.IborIndex](base_currency_index._thisptr),
                static_pointer_cast[_ii.IborIndex](quote_currency_index._thisptr),
                collateral_curve.handle,
                is_fx_base_currency_collateral_currency,
                is_basis_on_fx_base_currency_leg
            )
        )

cdef class MtMCrossCurrencyBasisSwapRateHelper(RelativeDateRateHelper):
     """Rate helper for bootstrapping over market-to-market cross-currency basis swaps

     Helper for a cross currency swap with resetting notional.
     This means that at each interest payment the notional on the MtM
     leg is being reset to reflect the changes in the FX rate - reducing
     the counterparty and FX risk of the structure.
     For more details see:
     N. Moreni, A. Pallavicini (2015)
     FX Modelling in Collateralized Markets: foreign measures, basis curves
     and pricing formulae.
     """

     def __init__(self, Quote basis, Period tenor, Natural fixing_days, Calendar calendar,
                  BusinessDayConvention convention, bool end_of_month, IborIndex base_currency_index,
                  IborIndex quote_currency_index, HandleYieldTermStructure collateral_curve,
                  bool is_fx_base_currency_collateral_currency,
                  bool is_basis_on_fx_base_currency_leg,
                  bool is_fx_base_currency_leg_resettable):
         self._thisptr.reset(
             new _ccyrh.MtMCrossCurrencyBasisSwapRateHelper(
                 basis.handle(),
                 deref(tenor._thisptr),
                 fixing_days,
                 calendar._thisptr,
                 convention,
                 end_of_month,
                 static_pointer_cast[_ii.IborIndex](base_currency_index._thisptr),
                 static_pointer_cast[_ii.IborIndex](quote_currency_index._thisptr),
                 collateral_curve.handle,
                 is_fx_base_currency_collateral_currency,
                 is_basis_on_fx_base_currency_leg,
                 is_fx_base_currency_leg_resettable,
             )
         )
