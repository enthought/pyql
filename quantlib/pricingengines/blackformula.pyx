include '../types.pxi'

from . cimport _blackformula as _bf
cimport quantlib.instruments._option as _opt

from quantlib.instruments._option cimport Type as OptionType

from math import sqrt, log

from quantlib.instruments.option import Call, Put

def blackFormula(OptionType option_type, Real strike, Real forward, Real stdDev,
                 Real discount=1.0, Real displacement=0.0):
    """ Black 1976 formula

    Parameters
    ----------

    option_type: str or option.Call/Put

    strike: float

    forward: float

    std_dev: float

    discount: float

    displacement: float


    .. warning::

        Instead of volatility it uses standard deviation,
        i.e. volatility*sqrt(timeToMaturity)

    """

    return _bf.blackFormula(option_type,
                            strike,
                            forward,
                            stdDev,
                            discount,
                            displacement)

def blackFormulaImpliedStdDev(OptionType cp, Real strike,
                    Real forward, Real blackPrice, Real discount,
                    Real TTM, guess=None,
                    Real displacement=0.0, Real accuracy=1.e-5,
                    Natural maxIterations=100):
    """
    Implied volatility calculation

    Implied volatility of an European vanilla option, with estimate of initial guess
    """
    cdef double oType
    if guess is None:
        if abs(float(forward - strike))/strike < .01:
        # first order approximation to N(x) = 1/2 + x/\sqrt{2 pi}
            oType = <double>cp
            guess = (blackPrice/discount - (oType/2.0) * (forward-strike)) * 5.0 / (forward+strike)
        else:
        # the inflexion point
            guess = sqrt(2.0*abs(log(forward/strike))/TTM)

        guess = guess * sqrt(TTM)

    return _bf.blackFormulaImpliedStdDev(cp,
                                   <Real> strike,
                                   <Real> forward,
                                   <Real> blackPrice,
                                   <Real> discount,
                                   <Real> displacement,
                                   <Real> guess,
                                   <Real> accuracy,
                                   <Natural> maxIterations)


def bachelier_black_formula(OptionType option_type, Real strike, Real forward, Real stdDev,
                            Real discount=1.0):
    """ Black style formula when forward is normal rather than
        log-normal. This is essentially the model of Bachelier.


    Parameters
    ==========

    option_type: str or option.Call/Put

    strike: float

    forward: float

    std_dev: float

    discount: float

    .. warning::
        Bachelier model needs absolute volatility, not
        percentage volatility. Standard deviation is
        absoluteVolatility*sqrt(timeToMaturity)

    """

    return _bf.bachelierBlackFormula(option_type,
                                     strike,
                                     forward,
                                     stdDev,
                                     discount)
