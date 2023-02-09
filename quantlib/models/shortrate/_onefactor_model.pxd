from quantlib.types cimport DiscountFactor, Rate, Real, Time
from quantlib.math._array cimport Array
from quantlib.models._model cimport ShortRateModel, AffineModel
from quantlib.handle cimport shared_ptr
from quantlib._stochastic_process cimport StochasticProcess1D

cdef extern from 'ql/models/shortrate/onefactormodel.hpp' namespace 'QuantLib' nogil:

    cdef cppclass OneFactorModel(ShortRateModel):
        cppclass ShortRateDynamics:
            ShortRateDynamics(const shared_ptr[StochasticProcess1D]& process)
            Real variable(Time t, Rate r)
            Rate shortRate(Time t, Real variable)
            shared_ptr[StochasticProcess1D]& process()
        shared_ptr[ShortRateDynamics] dynamics()

    cdef cppclass OneFactorAffineModel(OneFactorModel):
        Real discountBond(Time now, Time maturity, Rate rate)
