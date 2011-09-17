include '../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr
cimport quantlib.processes._black_scholes_process as _bsp

from quantlib.models.equity.heston_model cimport HestonModel
from quantlib.processes.black_scholes_process cimport GeneralizedBlackScholesProcess

cdef class VanillaOptionEngine:

    def __cinit__(self):
        self._thisptr = NULL
        self.process = None

    def __dealloc__(self):
        if self._thisptr is not NULL:
            print 'VanillaOptionEngine dealllocated'
            self.process = None
            del self._thisptr

cdef class AnalyticEuropeanEngine(VanillaOptionEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess]* process_ptr = \
            new shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                process._thisptr
            )
        
        self.process = process
        self._thisptr = new _vanilla.AnalyticEuropeanEngine(deref(process_ptr))

cdef class BaroneAdesiWhaleyApproximationEngine(VanillaOptionEngine):

    def __init__(self, GeneralizedBlackScholesProcess process):

        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess]* process_ptr = \
            new shared_ptr[_bsp.GeneralizedBlackScholesProcess](
                process._thisptr
            )
        
        self.process = process
        self._thisptr = new _vanilla.BaroneAdesiWhaleyApproximationEngine(
            deref(process_ptr)
        )

cdef class AnalyticHestonEngine:

    def __cinit__(self):
        self._thisptr = NULL

    def __dealloc__(self):
        pass # no need for deallocation because we use a boost::shared_ptr

    def __init__(self, HestonModel model, int integration_order=144):

        self._thisptr = new shared_ptr[AnalyticHestonEngine](
            new _vanilla.AnalyticHestonEngine(
                deref(model._thisptr),
                <Size>integration_order
            )
        )


