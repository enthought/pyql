from . cimport _multipathgenerator as _mpg
from quantlib.math.randomnumbers._randomsequencegenerator cimport RandomSequenceGenerator
from quantlib.math.randomnumbers._rngtraits cimport PseudoRandom as QlPseudoRandom, LowDiscrepancy as QlLowDiscrepancy, ZigguratPseudoRandom


cdef class PseudoRandomMultiPathGenerator:
    cdef _mpg.MultiPathGenerator[QlPseudoRandom.rsg_type]* _thisptr

cdef class LowDiscrepancyMultiPathGenerator:
    cdef _mpg.MultiPathGenerator[QlLowDiscrepancy.rsg_type]* _thisptr

cdef class ZigguratMultiPathGenerator:
    cdef _mpg.MultiPathGenerator[ZigguratPseudoRandom]* _thisptr
