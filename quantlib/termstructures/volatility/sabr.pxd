include "../../types.pxi"

cdef extern from 'ql/termstructures/volatility/sabr.hpp' namespace 'QuantLib':
    Real unsafeSabrVolatility(Rate strike,
                              Rate forward,
                              Time expiryTime,
                              Real alpha,
                              Real beta,
                              Real nu,
                              Real rho)

    Real unsafeShiftedSabrVolatility(Rate strike,
                                     Rate forward,
                                     Time expiryTime,
                                     Real alpha,
                                     Real beta,
                                     Real nu,
                                     Real rho,
                                     Real shift)

    Real sabrVolatility(Rate strike,
                        Rate forward,
                        Time expiryTime,
                        Real alpha,
                        Real beta,
                        Real nu,
                        Real rho)

    Real shiftedSabrVolatility(Rate strike,
                               Rate forward,
                               Time expriyTime,
                               Real alpha,
                               Real beta,
                               Real nu,
                               Real rho,
                               Real shift)

    void validateSabrParameters(Real alpha,
                                Real beta,
                                Real nu,
                                Real rho) except +
