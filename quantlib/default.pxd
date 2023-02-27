cdef extern from 'ql/default.hpp' namespace 'QuantLib::Protection':
    cpdef enum class Side:
        Buyer
        Seller
