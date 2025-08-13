from ..termstructure cimport TermStructure

cdef class InflationTermStructure(TermStructure):
    pass

cdef class ZeroInflationTermStructure(InflationTermStructure):
    pass

cdef class YoYInflationTermStructure(InflationTermStructure):
    pass
