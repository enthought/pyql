include '../../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector
from cython.operator cimport dereference as deref
from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
from quantlib.math.optimization cimport OptimizationMethod, EndCriteria
from quantlib.indexes.swap_index cimport SwapIndex
from quantlib.defines cimport QL_NULL_REAL
from quantlib.quotes cimport SimpleQuote
from quantlib.time.date cimport Period
from quantlib.time._period cimport Period as QlPeriod
from swaption_vol_structure cimport SwaptionVolatilityStructure
cimport _swaption_vol_cube1 as _svc1
cimport quantlib.indexes._swap_index as _si

cimport _swaption_vol_structure as _svs
cimport quantlib._quote as _qt

cdef extern from 'boost/move/core.hpp' namespace 'boost':
    cdef T move[T](T)

cdef class SwaptionVolCube1(SwaptionVolatilityCube):

    def __init__(self, SwaptionVolatilityStructure atm_vol_structure not None,
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
                 Real max_error_tolerance=QL_NULL_REAL,
                 OptimizationMethod opt_method not None=OptimizationMethod(),
                 Real error_accept=QL_NULL_REAL,
                 bool use_max_error=False,
                 Size max_guesses=50,
                 bool backward_flat=False,
                 Real cutoff_strike=0.0001):
        cdef:
            Handle[_svs.SwaptionVolatilityStructure] atm_vol_structure_handle = \
                Handle[_svs.SwaptionVolatilityStructure](atm_vol_structure._thisptr)
            vector[QlPeriod] option_tenors_vec
            vector[QlPeriod] swap_tenors_vec
            Period p
            SimpleQuote q
            vector[vector[Handle[_qt.Quote]]] vol_spreads_matrix
            vector[vector[Handle[_qt.Quote]]] parameters_guess_matrix
            list l

        for l in vol_spreads:
            vol_spreads_matrix.push_back(vector[Handle[_qt.Quote]]())
            for q in l:
                vol_spreads_matrix.back().push_back(move(Handle[_qt.Quote](q._thisptr)))

        for l in parameters_guess:
            parameters_guess_matrix.push_back(vector[Handle[_qt.Quote]]())
            for q in l:
                (parameters_guess_matrix.
                 back().
                 push_back(move(Handle[_qt.Quote](q._thisptr))))

        for p in option_tenors:
            option_tenors_vec.push_back(deref(p._thisptr))
        for p in swap_tenors:
            swap_tenors_vec.push_back(deref(p._thisptr))


        self._thisptr = shared_ptr[_svs.SwaptionVolatilityStructure](
            new _svc1.SwaptionVolCube1(
                atm_vol_structure_handle,
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
                cutoff_strike))
