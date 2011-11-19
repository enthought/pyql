# distutils: language = c++
# distutils: libraries = QuantLib
include '../../types.pxi'

from cython.operator cimport dereference as deref

cimport _bates_model as _bm
cimport _heston_model as _hm
from quantlib.handle cimport Handle, shared_ptr
from quantlib.processes.heston_process cimport HestonProcess
from quantlib.models.equity.heston_model cimport HestonModel

cdef class BatesModel(HestonModel):

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass # using a boost::shared_ptr / no need for deallocation

    def __init__(self, HestonProcess process, Real Lambda, Real nu, Real delta):

        self._thisptr = new shared_ptr[_hm.HestonModel](
            new _bm.BatesModel(deref(process._thisptr),
                               Lambda, nu, delta))
        
    # property Lambda:
    #     def __get__(self):
    #         return self._thisptr.get().lambda()

    property nu:
        def __get__(self):
            return (<_bm.BatesModel *> self._thisptr.get()).nu()

    property delta:
        def __get__(self):
            return (<_bm.BatesModel *> self._thisptr.get()).delta()


