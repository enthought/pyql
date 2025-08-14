"""European option on a single asset"""
from .vanillaoption cimport VanillaOption

cdef class EuropeanOption(VanillaOption):
    pass
