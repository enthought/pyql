include '../../types.pxi'

cdef class LowDiscrepancy:

    def __init__(self, Size dimension, BigNatural seed=0):
        self._thisptr = new InverseCumulativeRsg[SobolRsg, InverseCumulativeNormal](
                _rngtraits.LowDiscrepancy.make_sequence_generator(dimension, seed))

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr

    def __iter__(self):
        return self

    def __next__(self):
        return self._thisptr.nextSequence().value

    @property
    def dimension(self):
        return self._thisptr.dimension()

    def last_sequence(self):
        return self._thisptr.lastSequence().value
