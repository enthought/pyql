from quantlib.handle cimport shared_ptr
from . cimport _brownian_generator as _bg

cdef class BrownianGenerator:
    cdef shared_ptr[_bg.BrownianGenerator] gen

cdef class BrownianGeneratorFactory:
    cdef _bg.BrownianGeneratorFactory* factory
