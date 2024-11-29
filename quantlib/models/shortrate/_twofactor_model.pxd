from quantlib.types cimport DiscountFactor, Rate, Real, Time
from quantlib.math._array cimport Array
from quantlib.models._model cimport ShortRateModel, AffineModel
from quantlib.handle cimport shared_ptr
from quantlib._stochastic_process cimport StochasticProcess1D

cdef extern from 'ql/models/shortrate/twofactormodel.hpp' namespace 'QuantLib' nogil:

    cdef cppclass TwoFactorModel(ShortRateModel):
        cppclass ShortRateDynamics:
            ShortRateDynamics(shared_ptr[StochasticProcess1D]& xProcess,
                              shared_ptr[StochasticProcess1D]& yProcess,
                              Real correlation)
            Rate shortRate(Time t, Real x, Real y)
            shared_ptr[StochasticProcess1D]& xProcess()
            shared_ptr[StochasticProcess1D]& yProcess()
        shared_ptr[ShortRateDynamics] dynamics()
