cdef extern from "ql/position.hpp" namespace "QuantLib" nogil:
    cpdef enum class Position "QuantLib::Position::Type":
        Long
        Short
