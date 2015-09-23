include '../../types.pxi'

cdef extern from 'ql/models/shortrate/onefactormodel.hpp' namespace 'QuantLib':

    cdef cppclass OneFactorAffineModel:

        OneFactorAffineModel()
