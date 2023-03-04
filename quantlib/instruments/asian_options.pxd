from quantlib.instruments.option cimport OneAssetOption

cdef extern from 'ql/instruments/averagetype.hpp' namespace 'QuantLib::Average':
    cpdef enum class AverageType "QuantLib::Average::Type":
        Arithmetic
        Geometric

cdef class ContinuousAveragingAsianOption(OneAssetOption):
    pass
