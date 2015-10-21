include '../../types.pxi'

from quantlib.models._model cimport CalibratedModel


cdef extern from 'ql/models/shortrate/onefactormodel.hpp' namespace 'QuantLib':

    cdef cppclass OneFactorAffineModel(CalibratedModel):

        OneFactorAffineModel()
