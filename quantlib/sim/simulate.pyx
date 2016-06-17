include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from libcpp cimport bool

cimport quantlib.processes._heston_process as _hp
cimport quantlib.processes._stochastic_process as _sp

from quantlib.processes.heston_process cimport HestonProcess
from quantlib.processes.bates_process cimport BatesProcess
from quantlib.models.equity.heston_model cimport HestonModel
from quantlib.models.equity.bates_model cimport (
    BatesModel, BatesDetJumpModel, BatesDoubleExpModel, BatesDoubleExpDetJumpModel)

import numpy as np
cimport numpy as cnp

cdef extern from "simulate_support_code.hpp" namespace 'PyQL':

    void simulateMP(const shared_ptr[_sp.StochasticProcess]& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    bool antithetic_variates, double *res) except +

def simulate_model(model, int nbPaths, int nbSteps, Time horizon,
                   BigNatural seed, bool antithetic = True):
    cdef shared_ptr[_sp.StochasticProcess] sp
    cdef shared_ptr[_hp.HestonProcess] hp
    hp = (<HestonModel?>model)._thisptr.get().process()
    sp = <shared_ptr[_sp.StochasticProcess]>hp

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros((nbPaths+1, nbSteps+1), dtype=np.double)
    simulateMP(sp, nbPaths, nbSteps,
               horizon, seed, antithetic, <double*> res.data)
    return res
