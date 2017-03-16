include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from libcpp cimport bool

cimport quantlib.processes._heston_process as _hp
cimport quantlib.processes._stochastic_process as _sp

from quantlib.processes.heston_process cimport HestonProcess
from quantlib.models.equity.heston_model cimport HestonModel
from quantlib.time_grid cimport TimeGrid
cimport quantlib._time_grid as _tg

import numpy as np
cimport numpy as cnp

cdef extern from "simulate_support_code.hpp" namespace 'PyQL':

    void simulateMP(const shared_ptr[_sp.StochasticProcess]& process,
                    int nbPaths, _tg.TimeGrid& grid, BigNatural seed,
                    bool antithetic_variates, double *res) except +

def simulate_model(model, int nbPaths, TimeGrid grid, BigNatural seed,
                   bool antithetic=True):
    cdef shared_ptr[_sp.StochasticProcess] sp
    cdef shared_ptr[_hp.HestonProcess] hp
    hp = (<HestonModel?>model)._thisptr.get().process()
    sp = <shared_ptr[_sp.StochasticProcess]>hp

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.empty(
        (grid._thisptr.size(), nbPaths), dtype=np.double, order='F')
    simulateMP(sp, nbPaths, grid._thisptr, seed, antithetic, <double*> res.data)
    return res
