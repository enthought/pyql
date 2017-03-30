include 'types.pxi'

cdef class StochasticProcess:
    def size(self):
        return self._thisptr.get().size()

    def factors(self):
        return self._thisptr.get().factors()

cdef class StochasticProcess1D(StochasticProcess):

    def drift(self, Time t, Real x):
        return _get_StochasticProcess1D(self).drift(t, x)

    def diffusion(self, Time t, Real x):
        return _get_StochasticProcess1D(self).diffusion(t, x)

    def expectation(self, Time t0, Real x0, Time dt):
        return _get_StochasticProcess1D(self).expectation(t0, x0, dt)

    def std_deviation(self, Time t0, Real x0, Time dt):
        return _get_StochasticProcess1D(self).stdDeviation(t0, x0, dt)

    def variance(self, Time t0, Real x0, Time dt):
        return _get_StochasticProcess1D(self).stdDeviation(t0, x0, dt)

    @property
    def x0(self):
        return _get_StochasticProcess1D(self).x0()
