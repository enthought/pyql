include '../../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, make_shared, static_pointer_cast
from quantlib.math.optimization cimport OptimizationMethod, EndCriteria
from quantlib.indexes.swap_index cimport SwapIndex
from quantlib.utilities.null cimport Null
from quantlib.quote cimport Quote
from quantlib.time.date cimport Period
from quantlib.time._period cimport Period as QlPeriod
from .swaption_vol_structure cimport SwaptionVolatilityStructure
from . cimport _sabr_swaption_volatility_cube as _ssvc
cimport quantlib.indexes._swap_index as _si
cimport quantlib._quote as _qt

from . cimport _swaption_vol_structure as _svs
from ..._vol_term_structure cimport VolatilityTermStructure

cdef class SabrSwaptionVolatilityCube(SwaptionVolatilityCube):

    def __init__(self, atm_vol_structure not None,
                 list option_tenors not None,
                 list swap_tenors not None,
                 vector[Spread] strike_spreads,
                 list vol_spreads not None,
                 SwapIndex swap_index_base not None,
                 SwapIndex short_swap_index_base not None,
                 bool vega_weighted_smile_fit,
                 list parameters_guess not None,
                 vector[bool] is_parameter_fixed,
                 bool is_atm_calibrated,
                 EndCriteria end_criteria not None=EndCriteria.__new__(EndCriteria),
                 Real max_error_tolerance=Null[Real](),
                 OptimizationMethod opt_method not None=OptimizationMethod(),
                 Real error_accept=Null[Real](),
                 bool use_max_error=False,
                 Size max_guesses=50,
                 bool backward_flat=False,
                 Real cutoff_strike=0.0001):
        cdef:
            vector[QlPeriod] option_tenors_vec
            vector[QlPeriod] swap_tenors_vec
            Period p
            Quote q
            vector[vector[Handle[_qt.Quote]]] vol_spreads_matrix
            vector[vector[Handle[_qt.Quote]]] parameters_guess_matrix
            list l

        for l in vol_spreads:
            vol_spreads_matrix.push_back(vector[Handle[_qt.Quote]]())
            for q in l:
                vol_spreads_matrix.back().push_back(Handle[_qt.Quote](q._thisptr))

        for l in parameters_guess:
            parameters_guess_matrix.push_back(vector[Handle[_qt.Quote]]())
            for q in l:
                (parameters_guess_matrix.
                 back().
                 push_back(q.handle()))

        for p in option_tenors:
            option_tenors_vec.push_back(deref(p._thisptr))
        for p in swap_tenors:
            swap_tenors_vec.push_back(deref(p._thisptr))

        self._derived_ptr = make_shared[_ssvc.SabrSwaptionVolatilityCube](
            SwaptionVolatilityStructure.swaption_vol_handle(atm_vol_structure),
            option_tenors_vec,
            swap_tenors_vec,
            strike_spreads,
            vol_spreads_matrix,
            static_pointer_cast[_si.SwapIndex](swap_index_base._thisptr),
            static_pointer_cast[_si.SwapIndex](short_swap_index_base._thisptr),
            vega_weighted_smile_fit,
            parameters_guess_matrix,
            is_parameter_fixed,
            is_atm_calibrated,
            end_criteria._thisptr,
            max_error_tolerance,
            opt_method._thisptr,
            error_accept,
            use_max_error,
            max_guesses,
            backward_flat,
            cutoff_strike
        )
        self._thisptr = self._derived_ptr
