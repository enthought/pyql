from quantlib.types cimport Size
from . cimport _mt_brownian_generator as _mtbg

cdef class MTBrownianGenerator(BrownianGenerator):
    def __init__(self, Size factors, Size steps, unsigned long seed=0):
        self.gen.reset(new _mtbg.MTBrownianGenerator(factors, steps, seed))


cdef class MTBrownianGeneratorFactory(BrownianGeneratorFactory):
    def __init__(self, unsigned long seed=0):
        self.factory = new _mtbg.MTBrownianGeneratorFactory(seed)
