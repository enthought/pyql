from libcpp.vector cimport vector
from quantlib.types cimport Real, Size

cdef class BrownianGenerator:
    def next_step(self, vector[Real] v):
        """ len(v) needs to be equal to number of factors """
        return self.gen.get().nextStep(v)

    def next_path(self):
        return self.gen.get().nextPath()

    @property
    def number_of_factors(self):
        return self.gen.get().numberOfFactors()

    @property
    def number_of_steps(self):
        return self.gen.get().numberOfSteps()

cdef class BrownianGeneratorFactory:
    def create(self, Size factors, Size steps):
        cdef BrownianGenerator r = BrownianGenerator.__new__(BrownianGenerator)
        r.gen = self.factory.create(factors, steps)
        return r
