cdef extern from "ql/compounding.hpp" namespace "QuantLib":
    cpdef enum Compounding:
        Simple = 0
        Continuous = 1
        Compounded = 2
        SimpleThenCompounded
        CompoundedThenSimple
