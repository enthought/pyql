from quantlib.handle cimport shared_ptr
cimport _stochastic_process as _sp

cdef class StochasticProcess:
    cdef shared_ptr[_sp.StochasticProcess] _thisptr

cdef inline _sp.StochasticProcess1D* _get_StochasticProcess1D(
    StochasticProcess proc):
    return <_sp.StochasticProcess1D*>proc._thisptr.get()

cdef class StochasticProcess1D(StochasticProcess):
    pass
