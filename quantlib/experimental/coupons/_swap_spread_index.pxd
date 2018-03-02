include '../../types.pxi'
from libcpp.string cimport string
from quantlib.handle cimport shared_ptr
from quantlib.indexes._interest_rate_index cimport InterestRateIndex
from quantlib.indexes._swap_index cimport SwapIndex

cdef extern from 'ql/experimental/coupons/swapspreadindex.hpp' namespace 'QuantLib':
    cdef cppclass SwapSpreadIndex(InterestRateIndex):
        SwapSpreadIndex(const string& familyName,
                        const shared_ptr[SwapIndex]& swapIndex1,
                        const shared_ptr[SwapIndex]& swapIndex2,
                        const Real gearing1, # = 1.0,
                        const Real gearing2) # = -1.0)
        Real gearing1()
        Real gearing2()
