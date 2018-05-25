include "../../types.pxi"

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp cimport bool

cimport _smilesection as _ss
from quantlib.handle cimport shared_ptr, Handle
from quantlib.quotes cimport SimpleQuote
from quantlib._quote cimport Quote
from quantlib.math.optimization cimport EndCriteria, OptimizationMethod
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.daycounters.simple cimport Actual365Fixed

cdef inline _sis.SabrInterpolatedSmileSection* _get_siss(SabrInterpolatedSmileSection ref):
    return <_sis.SabrInterpolatedSmileSection*> ref._thisptr.get()

cdef class SabrInterpolatedSmileSection(SmileSection):
    def __init__(self, Date option_date not None,
                 SimpleQuote forward not None,
                 vector[Rate] strikes,
                 bool has_floating_strikes,
                 SimpleQuote atm_volatility,
                 vol_handles,
                 Real alpha, Real beta, Real nu, Real rho,
                 bool is_alpha_fixed=False, bool is_beta_fixed=False,
                 bool is_nu_fixed=False, bool is_rho_fixed=False,
                 bool vega_weighted=True,
                 EndCriteria end_criteria=EndCriteria.__new__(EndCriteria),
                 OptimizationMethod method=OptimizationMethod(),
                 DayCounter dc=Actual365Fixed(),
                 Real shift=0.):

        cdef vector[Handle[Quote]] vol_handles_cpp
        for vol_handle in vol_handles:
            vol_handles_cpp.push_back(Handle[Quote]((<SimpleQuote?>vol_handle)._thisptr))
        cdef Handle[Quote] forward_handle = Handle[Quote](forward._thisptr)
        cdef Handle[Quote] atm_volatility_handle = Handle[Quote](
            (<SimpleQuote?>atm_volatility)._thisptr)

        self._thisptr = shared_ptr[_ss.SmileSection](
            new _sis.SabrInterpolatedSmileSection(
                deref(option_date._thisptr),
                forward_handle,
                strikes,
                has_floating_strikes,
                atm_volatility_handle,
                vol_handles_cpp,
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
