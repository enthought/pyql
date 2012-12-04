# distutils: language = c++
# distutils: libraries = QuantLib

include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr

cimport quantlib.processes._heston_process as _hp
cimport quantlib.processes._stochastic_process as _sp
from quantlib.processes.heston_process cimport HestonProcess
from quantlib.processes.bates_process cimport BatesProcess
from quantlib.models.equity.heston_model cimport HestonModel
from quantlib.models.equity.bates_model cimport BatesModel, BatesDetJumpModel, BatesDoubleExpModel

import numpy as np
cimport numpy as cnp

cdef extern from "_simulate_support_code.hpp":

    void simulateMP(shared_ptr[_sp.StochasticProcess]& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    double *res) except +

def simulateHeston(HestonModel model, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed):

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros((nbPaths+1, nbSteps+1), dtype=np.double)

    proc = <HestonProcess> model.process()

    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr
    cdef shared_ptr[_sp.StochasticProcess]* hp_pt = <shared_ptr[_sp.StochasticProcess] *> tmp
  
    simulateMP(deref(<shared_ptr[_sp.StochasticProcess]*> hp_pt),
               nbPaths, nbSteps, horizon, seed, <double*> res.data)

    return res

def simulateBates(BatesModel model, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed):

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros((nbPaths+1, nbSteps+1), dtype=np.double)

    proc = <BatesProcess> model.process()
    
    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr
    cdef shared_ptr[_sp.StochasticProcess]* hp_pt = <shared_ptr[_sp.StochasticProcess] *> tmp
  
    simulateMP(deref(<shared_ptr[_sp.StochasticProcess]*> hp_pt),
               nbPaths, nbSteps, horizon, seed, <double*> res.data)

    return res


def simulateBatesDetJumpModel(BatesDetJumpModel model, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed):

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros((nbPaths+1, nbSteps+1), dtype=np.double)

    proc = <BatesProcess> model.process()
    
    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr
    cdef shared_ptr[_sp.StochasticProcess]* hp_pt = <shared_ptr[_sp.StochasticProcess] *> tmp
  
    simulateMP(deref(<shared_ptr[_sp.StochasticProcess]*> hp_pt),
               nbPaths, nbSteps, horizon, seed, <double*> res.data)

    ## TODO
    ## add jump process to simulation
    
    return res


def simulateBatesDoubleExpModel(BatesDoubleExpModel model, int nbPaths, int nbSteps,
	     Time horizon, BigNatural seed):

    cdef cnp.ndarray[cnp.double_t, ndim=2] res = np.zeros((nbPaths+1, nbSteps+1), dtype=np.double)

    proc = <HestonProcess> model.process()
    
    # intermediate cast to void per Cython doc:
    # http://docs.cython.org/src/reference/language_basics.html

    cdef void *tmp
    tmp = <void *> proc._thisptr
    cdef shared_ptr[_sp.StochasticProcess]* hp_pt = <shared_ptr[_sp.StochasticProcess] *> tmp
  
    simulateMP(deref(<shared_ptr[_sp.StochasticProcess]*> hp_pt),
               nbPaths, nbSteps, horizon, seed, <double*> res.data)

    ## TODO
    ## add double exp jump process to simulation
    
    return res

