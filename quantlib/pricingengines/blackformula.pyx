include '../types.pxi'

cimport _blackformula as _bf
cimport quantlib.instruments._option as _opt
from quantlib.instruments.payoffs import Call, Put
from math import sqrt, log

from quantlib.instruments._payoffs cimport OptionType

STR_TO_OPTION_TYPE = {'C': Call, 'P':Put}

def blackFormula(option_type, Real strike,
                      Real forward, Real stdDev, Real discount=1.0, Real displacement=0.0):
    """ Black 1976 formula

    Parameters
    ==========

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

    if isinstance(option_type, str):
        if option_type.upper() not in STR_TO_OPTION_TYPE:
            raise ValueError(
                'Option type must be one of {0}'.format(
                    ','.join(STR_TO_OPTION_TYPE.keys())
                )
            )
        else:
            option_type = STR_TO_OPTION_TYPE[option_type.upper()]

    return _bf.blackFormula(<_opt.Type>option_type,
                      <Real> strike,
                      <Real> forward,
                      <Real> stdDev,
                      <Real> discount,
                      <Real> displacement)

def blackFormulaImpliedStdDev(cp, Real strike,
                    Real forward, Real blackPrice, Real discount,
                    Real TTM, guess=None,
                    Real displacement=0.0, Real accuracy=1.e-5,
                    Natural maxIterations=100):
    """
    Implied volatility calculation

    Implied volatility of an European vanilla option, with estimate of initial guess
    """

    if isinstance(cp, str):   # Changed from basestring for Py2/3 compatibility
        cpType = STR_TO_OPTION_TYPE[cp.upper()]
    else:
        cpType = cp

    if guess is None:
        if abs(float(forward - strike))/strike < .01:
        # first order approximation to N(x) = 1/2 + x/\sqrt{2 pi}
            oType = 1 if cpType is Call else -1
            guess = (blackPrice/discount - (oType/2.0) * (forward-strike)) * 5.0 / (forward+strike)
        else:
        # the inflexion point
            guess = sqrt(2.0*abs(log(forward/strike))/TTM)

        guess = guess * sqrt(TTM)

    return _bf.blackFormulaImpliedStdDev(<_opt.Type> cpType,
                                   <Real> strike,
                                   <Real> forward,
                                   <Real> blackPrice,
                                   <Real> discount,
                                   <Real> displacement,
                                   <Real> guess,
                                   <Real> accuracy,
                                   <Natural> maxIterations)
