include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
from libcpp cimport bool

cimport quantlib.processes._heston_process as _hp
cimport quantlib.processes._stochastic_process as _sp

from quantlib.processes.heston_process cimport HestonProcess
from quantlib.processes.bates_process cimport BatesProcess
from quantlib.models.equity.heston_model cimport HestonModel
from quantlib.models.equity.bates_model cimport BatesModel, BatesDetJumpModel, BatesDoubleExpModel

import numpy as np
cimport numpy as cnp

cdef extern from "simulate_support_code.hpp" namespace 'PyQL':

    void simulateMP(shared_ptr[_sp.StochasticProcess]& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    bool antithetic_variates, double *res) except +

cdef simulate_sub(void *tmp, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed, bool antithetic=True):

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros((nbPaths+1, nbSteps+1), dtype=np.double)

    cdef shared_ptr[_sp.StochasticProcess]* hp_pt = <shared_ptr[_sp.StochasticProcess] *> tmp
  
    simulateMP(deref(<shared_ptr[_sp.StochasticProcess]*> hp_pt),
               nbPaths, nbSteps, horizon, seed, antithetic, <double*> res.data)

    return res

def simulateHeston(HestonModel model, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed, bool antithetic=True):

    proc = <HestonProcess> model.process()

    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr

    return simulate_sub(tmp, nbPaths, nbSteps,
	     horizon, seed, antithetic)


def simulateBates(BatesModel model, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed, bool antithetic=True):

    proc = <BatesProcess> model.process()
    
    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr

    return simulate_sub(tmp, nbPaths, nbSteps,
	     horizon, seed, antithetic)


def simulateBatesDetJumpModel(BatesDetJumpModel model, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed, bool antithetic=True):

    proc = <BatesProcess> model.process()
    
    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr

    res = simulate_sub(tmp, nbPaths, nbSteps,
	     horizon, seed, antithetic)

    ## TODO
    ## add jump process to simulation
    
    return res


def simulateBatesDoubleExpModel(BatesDoubleExpModel model, int nbPaths,
                                int nbSteps,
	     Time horizon, BigNatural seed, bool antithetic=True):

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros((nbPaths+1, nbSteps+1), dtype=np.double)

    proc = <HestonProcess> model.process()
    
    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr

    res = simulate_sub(tmp, nbPaths, nbSteps,
	     horizon, seed, antithetic)

     # parameters of double exponential jump model
     # Lambda   jump occurence: rate of Poisson process
     # nuUp     up jump intensity (exp dist)
     # nuDown   down jump intensity
     # p        prob of up jump

## TODO
    ## add double exp jump process to simulation
    
    return res

