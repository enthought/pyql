from . cimport _optionlet_volatility_structure as _ov
from quantlib.ext cimport shared_ptr
from quantlib.handle cimport Handle

cdef class OptionletVolatilityStructure:
    cdef shared_ptr[_ov.OptionletVolatilityStructure] _thisptr
