from quantlib.pricingengines.engine cimport PricingEngine
from ._analytic_heston_engine cimport AnalyticHestonEngine as AHE

cdef class AnalyticHestonEngine(PricingEngine):
    pass

cdef class Integration:
    cdef AHE.Integration* itg

cdef extern from "ql/pricingengines/vanilla/analytichestonengine.hpp" \
    namespace "QuantLib::AnalyticHestonEngine":
     cpdef enum ComplexLogFormula:
         # Gatheral form of characteristic function w/o control variate
         Gatheral,
         # old branch correction form of the characteristic function w/o control variate
         BranchCorrection,
         # Gatheral form with Andersen-Piterbarg control variate
         AndersenPiterbarg,
         # same as AndersenPiterbarg, but a slightly better control variate
         AndersenPiterbargOptCV
         # Gatheral form with asymptotic expansion of the characteristic function as control variate
         # https://hpcquantlib.wordpress.com/2020/08/30/a-novel-control-variate-for-the-heston-model
         AsymptoticChF
         # auto selection of best control variate algorithm from above
         OptimalCV
