from quantlib.types cimport Time
from . cimport _forwardmeasureprocess as _fmp

cdef class ForwardMeasureProcess(StochasticProcess):

    @property
    def forward_measure_time(self):
        return (<_fmp.ForwardMeasureProcess*>self._thisptr.get()).getForwardMeasureTime()

    @forward_measure_time.setter
    def forward_measure_time(self, Time t):
        (<_fmp.ForwardMeasureProcess*>self._thisptr.get()).setForwardMeasureTime(t)

cdef class ForwardMeasureProcess1D(StochasticProcess1D):

    @property
    def forward_measure_time(self):
        return (<_fmp.ForwardMeasureProcess1D*>self._thisptr.get()).getForwardMeasureTime()

    @forward_measure_time.setter
    def forward_measure_time(self, Time t):
        (<_fmp.ForwardMeasureProcess1D*>self._thisptr.get()).setForwardMeasureTime(t)
