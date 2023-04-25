cdef extern from 'ql/default.hpp' namespace 'QuantLib::Protection':
    cpdef enum class Protection "QuantLib::Protection::Side":
        Buyer
        Seller
