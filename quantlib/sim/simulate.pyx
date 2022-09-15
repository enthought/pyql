include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from libcpp cimport bool

cimport quantlib._stochastic_process as _sp

from quantlib.stochastic_process cimport StochasticProcess
from quantlib.time_grid cimport TimeGrid
cimport quantlib._time_grid as _tg

import numpy as np
cimport numpy as cnp

cdef extern from "simulate_support_code.hpp" namespace 'PyQL':

    void simulateMP(const shared_ptr[_sp.StochasticProcess]& process,
                    int nbPaths, _tg.TimeGrid& grid, BigNatural seed,
                    bool antithetic_variates, double *res) except +

def simulate_process(StochasticProcess process not None, int nbPaths, TimeGrid grid,
                     BigNatural seed, bool antithetic=True):
    """Draws random paths from a stochastic process.

    Parameters
    ----------
    process : StochasticProcess
        Process to simulate.
    nbPath : int
        Number of paths.
    grid : TimeGrid
        Time grid for the simulation.
    seed : int
        Seed for the random number generator.
    antithetic : bool (default True)
        Use antithetic variables.
    """
    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.empty(
        (grid._thisptr.size(), nbPaths), dtype=np.double, order='F')
    simulateMP(process._thisptr, nbPaths, grid._thisptr, seed, antithetic, <double*> res.data)
    return res
