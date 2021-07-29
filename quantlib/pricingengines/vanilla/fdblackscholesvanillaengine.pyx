from libcpp cimport bool

from cython.operator cimport dereference as deref
from quantlib._defines cimport QL_NULL_REAL
from quantlib.handle cimport static_pointer_cast, shared_ptr
from quantlib.types cimport Size, Real
from quantlib.pricingengines._pricing_engine cimport PricingEngine as QlPricingEngine
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.methods.finitedifferences.solvers.fdmbackwardsolver cimport FdmSchemeDesc

cimport quantlib.processes._black_scholes_process as _bsp

cdef class FdBlackScholesVanillaEngine(PricingEngine):
    def __init__(self, GeneralizedBlackScholesProcess process,
                 Size t_grid=100,
                 Size x_grid=100,
                 Size damping_steps=0,
                 FdmSchemeDesc scheme=FdmSchemeDesc.Douglas(),
                 bool local_vol=False,
                 Real illegal_local_vol_overwrite=-QL_NULL_REAL,
                 CashDividendModel cash_dividend_model=Spot):
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)
        self._thisptr.reset(
            new _fdbs.FdBlackScholesVanillaEngine(
                process_ptr,
                t_grid,
                x_grid,
                damping_steps,
                deref(scheme._thisptr),
                local_vol,
                illegal_local_vol_overwrite,
                cash_dividend_model
            )
        )
