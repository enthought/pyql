include '../types.pxi'
from quantlib.handle cimport Handle
from quantlib._quote cimport Quote
from _coupon_pricer cimport CmsCouponPricer
from quantlib.termstructures.volatility.swaption._swaption_vol_structure \
    cimport SwaptionVolatilityStructure

cdef extern from 'ql/cashflows/conundrumpricer.hpp' namespace 'QuantLib::GFunctionFactory':
    cdef enum YieldCurveModel:
        Standard
        ExactYield
        ParallelShifts
        NonParallelShifts

cdef extern from 'ql/cashflows/conundrumpricer.hpp' namespace 'QuantLib':
    cdef cppclass HaganPricer(CmsCouponPricer):
        pass

    cdef cppclass NumericHaganPricer(CmsCouponPricer):
        NumericHaganPricer(
                const Handle[SwaptionVolatilityStructure]& swaptionVol,
                YieldCurveModel modelOfYieldCurve,
                const Handle[Quote]& meanReversion,
                Rate lowerLimit, # = 0.0,
                Rate upperLimit, # = 1.0,
                Real precision) # = 1.0e-6,

    cdef cppclass AnalyticHaganPricer(HaganPricer):
        AnalyticHaganPricer(
            const Handle[SwaptionVolatilityStructure]& swaptionVol,
            YieldCurveModel modelOfYieldCurve,
            const Handle[Quote]& meanReversion)
