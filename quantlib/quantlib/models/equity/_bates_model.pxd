# distutils: language = c++
# distutils: libraries = QuantLib

include '../../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.models.equity._heston_model cimport HestonModel
cimport quantlib.processes._heston_process as _hp

cdef extern from 'ql/models/equity/batesmodel.hpp' namespace 'QuantLib':

    cdef cppclass BatesModel(HestonModel):

        BatesModel() # fake empty constructor due to Cython issue
        BatesModel(shared_ptr[_hp.BatesProcess]& process) except +

        Real Lambda 'lambda'() except + # lambda is a python keyword
        Real nu() except +
        Real delta() except +

    cdef cppclass BatesDetJumpModel(BatesModel):
        BatesDetJumpModel()
        BatesDetJumpModel(shared_ptr[_hp.BatesProcess]& process,
                   Real kappaLambda,
                   Real thetaLambda,
        )

        Real kappaLambda() except +
        Real thetaLambda() except +

    cdef cppclass BatesDoubleExpModel(HestonModel):
        BatesDoubleExpModel()
        BatesDoubleExpModel(shared_ptr[_hp.HestonProcess] & process,
                   Real Lambda,
                   Real nuUp,
                   Real nuDown,
                   Real p) except +

        Real p() except +
        Real nuDown() except +
        Real nuUp() except +
        Real Lambda 'lambda'() except +

    cdef cppclass BatesDoubleExpDetJumpModel(BatesDoubleExpModel):
        BatesDoubleExpDetJumpModel()
        BatesDoubleExpDetJumpModel(shared_ptr[_hp.HestonProcess]& process,
            Real Lambda,
            Real nuUp,
            Real nuDown,
            Real p,
            Real kappaLambda,
            Real thetaLambda) except +

        Real kappaLambda() except +
        Real thetaLambda() except +
