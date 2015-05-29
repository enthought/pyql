from quantlib.handle cimport shared_ptr
cimport _optionlet_volatility_structure as _ov

cdef class OptionletVolatilityStructure:
    cdef shared_ptr[_ov.OptionletVolatilityStructure]* _thisptr

