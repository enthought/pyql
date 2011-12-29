# distutils: language = c++
# distutils: libraries = QuantLib
include '../../types.pxi'

from cython.operator cimport dereference as deref

cimport _bates_model as _bm
cimport _heston_model as _hm
from quantlib.handle cimport Handle, shared_ptr
from quantlib.processes.heston_process cimport HestonProcess
from quantlib.processes.bates_process cimport BatesProcess
from quantlib.models.equity.heston_model cimport HestonModel

cdef class BatesModel:

    def __cinit__(self):
        self._thisptr = NULL

    ## def __dealloc__(self):
    ##     if self._thisptr is not NULL:
    ##         print('bates dealloc')
    ##         del self._thisptr

    def __init__(self, BatesProcess process):
        self._thisptr = new shared_ptr[_hm.HestonModel](
            new _bm.BatesModel(deref(process._thisptr)))

    property Lambda:
        def __get__(self):
            return (<_bm.BatesModel*> self._thisptr.get()).Lambda()

    property nu:
        def __get__(self):
            return (<_bm.BatesModel *> self._thisptr.get()).nu()

    property delta:
        def __get__(self):
            return (<_bm.BatesModel *> self._thisptr.get()).delta()


