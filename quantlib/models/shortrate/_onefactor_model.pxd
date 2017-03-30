include '../../types.pxi'

from quantlib.models._model cimport CalibratedModel
from quantlib.handle cimport shared_ptr
from quantlib._stochastic_process cimport StochasticProcess1D

cdef extern from 'ql/models/shortrate/onefactormodel.hpp' namespace 'QuantLib':

    cdef cppclass OneFactorAffineModel(CalibratedModel):
        OneFactorAffineModel()
        Real discountBond(Time now, Time maturity, Rate rate)
        cppclass ShortRateDynamics:
            ShortRateDynamics(const shared_ptr[StochasticProcess1D]& process)
            Real variable(Time t, Rate r)
            Rate shortRate(Time t, Real variable)
            shared_ptr[StochasticProcess1D]& process()
        shared_ptr[ShortRateDynamics] dynamics()
