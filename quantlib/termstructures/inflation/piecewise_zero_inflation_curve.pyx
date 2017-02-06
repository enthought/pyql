include '../../types.pxi'

from libcpp cimport bool

from quantlib.handle cimport shared_ptr, Handle, RelinkableHandle
from quantlib.time._calendar cimport Calendar
from quantlib.time.date cimport Date, Period
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.inflation.interpolated_zero_inflation_curve  \
    cimport InterpolatedZeroInflationCurve

from enum import IntEnum

globals()["BootstrapTrait"] = IntEnum('BootstrapTrait',
        [('Discount', 0), ('ZeroYield', 1), ('ForwardRate', 2)])
globals()["Interpolator"] = IntEnum('Interpolator',
        [('Linear', 0), ('LogLinear', 1), ('BackwardFlat', 2)])

cdef class PiecewiseZeroInflationCurve(InterpolatedZeroInflationCurve):
    def __init__(BoostrapTrait trait, Interpolator interpolator,
                 Date reference_date not None, Calendar not None,
                 DayCounter day_counter not None, Period lag not None,
                 Frequency frequency, bool index_is_interpolated,
                 Rate base_zero_rate, YieldTermStructure nominal_ts,
                 list instruments, Real accuracy=1e-12):
        pass
