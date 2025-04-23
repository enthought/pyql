"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.types cimport Real
from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.termstructures.volatility.volatilitytype cimport VolatilityType
from quantlib.time._daycounter cimport DayCounter
from quantlib.indexes._ibor_index cimport IborIndex
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.models._calibration_helper cimport BlackCalibrationHelper, CalibrationErrorType
from quantlib.instruments._swaption cimport Swaption
from quantlib.instruments._fixedvsfloatingswap cimport FixedVsFloatingSwap
cimport quantlib._quote as _qt

cdef extern from 'ql/models/shortrate/calibrationhelpers/swaptionhelper.hpp' namespace 'QuantLib':

    cdef cppclass SwaptionHelper(BlackCalibrationHelper):

        SwaptionHelper(Period& maturity,
                       Period& length,
                       Handle[_qt.Quote]& volatility,
                       shared_ptr[IborIndex]& index,
                       Period& fixedLegTenor,
                       DayCounter& fixedLegDayCounter,
                       DayCounter& floatingLegDayCounter,
                       Handle[YieldTermStructure]& termStructure,
                       CalibrationErrorType errorType,
                       Real strike,
                       Real nominal,
                       VolatilityType type, # = ShiftedLognormal,
                       Real shift # = 0.0
                       ) except +
        shared_ptr[FixedVsFloatingSwap] underlying()
        shared_ptr[Swaption] swaption()

    # this should really be a constructor but cython can't disambiguate the
    # constructors otherwise
    SwaptionHelper* SwaptionHelper_ "new QuantLib::SwaptionHelper"(
        Date& maturity,
        Period& length,
        Handle[_qt.Quote]& volatility,
        shared_ptr[IborIndex]& index,
        Period& fixedLegTenor,
        DayCounter& fixedLegDayCounter,
        DayCounter& floatingLegDayCounter,
        Handle[YieldTermStructure]& termStructure,
        CalibrationErrorType errorType,
        Real strike,
        Real nominal,
        VolatilityType type, # = ShiftedLognormal,
        Real shift # = 0.0
    ) except +
    SwaptionHelper* SwaptionHelper2_ "new QuantLib::SwaptionHelper"(
        Date& maturity,
        Date& length,
        Handle[_qt.Quote]& volatility,
        shared_ptr[IborIndex]& index,
        Period& fixedLegTenor,
        DayCounter& fixedLegDayCounter,
        DayCounter& floatingLegDayCounter,
        Handle[YieldTermStructure]& termStructure,
        CalibrationErrorType errorType,
        Real strike,
        Real nominal,
        VolatilityType type, # = ShiftedLognormal,
        Real shift # = 0.0
    ) except +
