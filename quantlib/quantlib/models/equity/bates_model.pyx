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

cdef class BatesDetJumpModel:

    def __cinit__(self):
        self._thisptr = NULL

    def __init__(self, BatesProcess process,
                 kappaLambda=1.0, thetaLambda=0.1):
        self._thisptr = new shared_ptr[_hm.HestonModel](
        new _bm.BatesDetJumpModel(deref(process._thisptr),
                                  kappaLambda,
                                  thetaLambda))

    property kappaLambda:
        def __get__(self):
            return (<_bm.BatesDetJumpModel*> self._thisptr.get()).kappaLambda()

    property thetaLambda:
        def __get__(self):
            return (<_bm.BatesDetJumpModel*> self._thisptr.get()).thetaLambda()

cdef class BatesDoubleExpModel:

    def __cinit__(self):
        self._thisptr = NULL

    def __init__(self, HestonProcess process,
                 Lambda=0.1,
                 nuUp=0.1, nuDown=0.1,
                 p=0.5):
        self._thisptr = new shared_ptr[_hm.HestonModel](
            new _bm.BatesDoubleExpModel(deref(process._thisptr),
                                        Lambda, nuUp, nuDown, p))

    property Lambda:
        def __get__(self):
            return (<_bm.BatesDoubleExpModel*> self._thisptr.get()).Lambda()

    property nuUp:
        def __get__(self):
            return (<_bm.BatesDoubleExpModel *> self._thisptr.get()).nuUp()

    property nuDown:
        def __get__(self):
            return (<_bm.BatesDoubleExpModel *> self._thisptr.get()).nuDown()

    property p:
        def __get__(self):
            return (<_bm.BatesDoubleExpModel *> self._thisptr.get()).p()
