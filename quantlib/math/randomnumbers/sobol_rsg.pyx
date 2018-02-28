include '../../types.pxi'
from _sobol_rsg cimport SobolRsg as QlSobolRsg

cpdef enum DirectionIntegers:
    Unit=0
    Jaeckel=1
    SobolLevitan=2
    SobolLevitanLemieux=3
    JoeKuoD5=4
    JoeKuoD6=5
    JoeKuoD7=6
    Kuo=7
    Kuo2=8
    Kuo3=9

cdef class SobolRsg:
    def __init__(self, Size dimensionality,
            int seed=0,
            QlSobolRsg.DirectionIntegers direction_integers=Jaeckel):
       self._thisptr = new QlSobolRsg(dimensionality,
               seed,
               direction_integers)

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __iter__(self):
        return self

    def __next__(self):
        return self._thisptr.nextSequence().value

    def skip_to(self, int n):
        self._thisptr.skipTo(n)

