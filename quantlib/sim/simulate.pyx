# distutils: language = c++
# distutils: libraries = QuantLib

include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

cimport quantlib.processes._heston_process as _hp
from quantlib.processes.heston_process cimport HestonProcess

import numpy as np
cimport numpy as cnp

cdef extern from "simulate_support_code.hpp":

    void simulateMP(shared_ptr[_hp.HestonProcess]& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    double *res) except +

def simulate(HestonProcess process, int nbPaths, int nbSteps, Time horizon,
             BigNatural seed):

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros(
        (nbPaths+1, nbSteps+1), dtype=np.double
    )

    simulateMP(
        deref(<shared_ptr[_hp.HestonProcess]*> process._thisptr), nbPaths,
        nbSteps, horizon, seed, <double*> res.data
    )

    return res

