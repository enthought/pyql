include "../../types.pxi"

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp cimport bool

from . cimport _smilesection as _ss
from quantlib.handle cimport shared_ptr, Handle
from quantlib.quotes cimport Quote
cimport quantlib._quote as _qt
from quantlib.math.optimization cimport EndCriteria, OptimizationMethod
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.daycounters.simple cimport Actual365Fixed

cdef inline _sis.SabrInterpolatedSmileSection* _get_siss(SabrInterpolatedSmileSection ref):
    return <_sis.SabrInterpolatedSmileSection*> ref._thisptr.get()

cdef class SabrInterpolatedSmileSection(SmileSection):
    def __init__(self, Date option_date not None,
                 forward,
                 vector[Rate] strikes,
                 bool has_floating_strikes,
                 atm_volatility,
                 list vol_handles,
                 Real alpha, Real beta, Real nu, Real rho,
                 bool is_alpha_fixed=False, bool is_beta_fixed=False,
                 bool is_nu_fixed=False, bool is_rho_fixed=False,
                 bool vega_weighted=True,
                 EndCriteria end_criteria=EndCriteria.__new__(EndCriteria),
                 OptimizationMethod method=OptimizationMethod(),
                 DayCounter dc=Actual365Fixed(),
                 Real shift=0.):

        cdef vector[Handle[_qt.Quote]] _vol_handles
        cdef Handle[_qt.Quote] forward_handle
        cdef Handle[_qt.Quote] atm_volatility_handle
        cdef Quote q
        cdef vector[Volatility] _vols
        cdef Real q_real
        if isinstance(forward, Quote):
            forward_handle = Handle[_qt.Quote]((<Quote>forward)._thisptr)
            for q in vol_handles:
                _vol_handles.push_back(Handle[_qt.Quote](q._thisptr))
            atm_volatility_handle = Handle[_qt.Quote](
                (<Quote>atm_volatility)._thisptr)
            self._thisptr = shared_ptr[_ss.SmileSection](
                new _sis.SabrInterpolatedSmileSection(
                    deref(option_date._thisptr),
                    forward_handle,
                    strikes,
                    has_floating_strikes,
                    atm_volatility_handle,
                    _vol_handles,
                    alpha, beta, nu, rho,
                    is_alpha_fixed, is_beta_fixed, is_nu_fixed, is_rho_fixed, vega_weighted,
                    end_criteria._thisptr, method._thisptr, deref(dc._thisptr), shift))
        elif isinstance(forward, float):
            for q_real in vol_handles:
                _vols.push_back(q_real)
            self._thisptr = shared_ptr[_ss.SmileSection](
                _sis.SabrInterpolatedSmileSection_(
                    deref(option_date._thisptr),
                    <Rate>forward,
                    strikes,
                    has_floating_strikes,
                    <Volatility>atm_volatility,
                    _vols,
                    alpha, beta, nu, rho,
                    is_alpha_fixed, is_beta_fixed, is_nu_fixed, is_rho_fixed, vega_weighted,
                    end_criteria._thisptr, method._thisptr, deref(dc._thisptr), shift))


    @property
    def alpha(self):
        return _get_siss(self).alpha()

    @property
    def beta(self):
        return _get_siss(self).beta()

    @property
    def nu(self):
        return _get_siss(self).nu()

    @property
    def rho(self):
        return _get_siss(self).rho()

    @property
    def rms_error(self):
        return _get_siss(self).rmsError()

    @property
    def max_error(self):
        return _get_siss(self).maxError()

    @property
    def end_criteria(self):
        return _get_siss(self).endCriteria()
