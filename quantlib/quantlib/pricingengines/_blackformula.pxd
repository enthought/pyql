# distutils: language = c++
# distutils: libraries = QuantLib

include '../types.pxi'
from quantlib.instruments._option cimport Type as OptionType

cdef extern from 'ql/pricingengines/blackformula.hpp' namespace 'QuantLib':

    Real blackFormula(OptionType optionType,
                      Real strike,
                      Real forward,
                      Real stdDev,
                      Real discount,
                      Real displacement) except +

    Real blackFormulaImpliedStdDev(OptionType optionType,
                                   Real strike,
                                   Real forward,
                                   Real blackPrice,
                                   Real discount,
                                   Real displacement,
                                   Real guess,
                                   Real accuracy,
                                   Natural maxIterations) except +
