def unsafe_sabr_volatility(Rate strike,
                           Rate forward,
                           Time expiryTime,
                           Real alpha,
                           Real beta,
                           Real nu,
                           Real rho):
    return unsafeSabrVolatility(strike, forward, expiryTime,
                                alpha, beta, nu, rho)

def unsafe_shifted_sabr_volatility(Rate strike,
                                   Rate forward,
                                   Time expiryTime,
                                   Real alpha,
                                   Real beta,
                                   Real nu,
                                   Real rho,
                                   Real shift):
    return unsafeShiftedSabrVolatility(strike, forward, expiryTime,
                                       alpha, beta, nu, rho, shift)

def sabr_volatility(Rate strike,
                    Rate forward,
                    Time expiryTime,
                    Real alpha,
                    Real beta,
                    Real nu,
                    Real rho):
    return sabrVolatility(strike, forward, expiryTime,
                          alpha, beta, nu, rho)

def shifted_sabr_volatility(Rate strike,
                            Rate forward,
                            Time expriyTime,
                            Real alpha,
                            Real beta,
                            Real nu,
                            Real rho,
                            Real shift):
    return shiftedSabrVolatility(strike, forward, expriyTime,
                                 alpha, beta, nu, rho, shift)

def validate_sabr_parameters(Real alpha,
                             Real beta,
                             Real nu,
                             Real rho):
    return validateSabrParameters(alpha, beta, nu, rho)
