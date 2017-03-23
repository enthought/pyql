include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, static_pointer_cast
from libcpp cimport bool

cimport quantlib.processes._heston_process as _hp
cimport quantlib.processes._stochastic_process as _sp

from quantlib.processes.heston_process cimport HestonProcess
from quantlib.processes.hullwhite_process cimport HullWhiteProcess
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.time_grid cimport TimeGrid
cimport quantlib._time_grid as _tg

import numpy as np
cimport numpy as cnp

cdef extern from "simulate_support_code.hpp" namespace 'PyQL':

    void simulateMP(const shared_ptr[_sp.StochasticProcess]& process,
                    int nbPaths, _tg.TimeGrid& grid, BigNatural seed,
                    bool antithetic_variates, double *res) except +

def simulate_process(process, int nbPaths, TimeGrid grid, BigNatural seed,
                     bool antithetic=True):
    cdef shared_ptr[_sp.StochasticProcess] sp
    if isinstance(process, HestonProcess):
        sp = static_pointer_cast[_sp.StochasticProcess](deref(
            (<HestonProcess>process)._thisptr))
    elif isinstance(process, HullWhiteProcess):
        sp = static_pointer_cast[_sp.StochasticProcess](deref(
            (<HullWhiteProcess>process)._thisptr))
    elif isinstance(process, GeneralizedBlackScholesProcess):
        sp = static_pointer_cast[_sp.StochasticProcess](deref(
            (<GeneralizedBlackScholesProcess>process)._thisptr))
    else:
        raise TypeError("process needs to be a HestonProcess, HullWhiteProcess " \
                        "or GeneralizedBlackScholesProcess instance")
    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.empty(
        (grid._thisptr.size(), nbPaths), dtype=np.double, order='F')
    simulateMP(sp, nbPaths, grid._thisptr, seed, antithetic, <double*> res.data)
    return res
