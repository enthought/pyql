from . cimport _compounding

cpdef enum Compounding:
    Simple = _compounding.Simple
    Compounded = _compounding.Compounded
    Continuous = _compounding.Continuous
    SimpleThenCompounded = _compounding.SimpleThenCompounded
    CompoundedThenSimple = _compounding.CompoundedThenSimple
