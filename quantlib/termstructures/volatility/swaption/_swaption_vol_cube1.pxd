include '../../../types.pxi'
from libcpp.vector cimport vector
from libcpp cimport bool
from ._swaption_vol_structure cimport SwaptionVolatilityStructure
from ._swaption_vol_cube cimport SwaptionVolatilityCube
from .._sabr_smile_section cimport SabrSmileSection
from quantlib.handle cimport Handle, shared_ptr
from quantlib._quote cimport Quote
from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.math._optimization cimport EndCriteria, OptimizationMethod
from quantlib.math._matrix cimport Matrix
from quantlib.math._interpolations cimport SABRInterpolation
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period

cdef extern from 'ql/termstructures/volatility/swaption/swaptionvolcube1.hpp' namespace 'QuantLib':
    cdef cppclass SwaptionVolCube1x[Model](SwaptionVolatilityCube):
        cppclass Cube:
            Cube(const vector[Date]& optionDates,
                 const vector[Period]& swapTenors,
                 const vector[Time]& optionTimes,
                 const vector[Time]& swapLengths,
                 Size nLayers,
                 bool extrapolation, # = true,
                 bool backwardFlat) # = false)
            Cube(const Cube&)
            void setElement(Size IndexOfLayer,
                            Size IndexOfRow,
                            Size IndexOfColumn,
                            Real x)
            void setPoints(const vector[Matrix]& x)
            void setPoint(const Date& optionDate,
                          const Period& swapTenor,
                          const Time optionTime,
                          const Time swapLengths,
                          const vector[Real]& point)
            void setLayer(Size i,
                          const Matrix& x)
            void expandLayers(Size i,
                              bool expandOptionTimes,
                              Size j,
                              bool expandSwapLengths)
            const vector[Date]& optionDates()
            const vector[Period]& swapTenors()
            const vector[Time]& optionTimes()
            const vector[Time]& swapLengths()
            const vector[Matrix]& points()
            vector[Real] operator()(const Time optionTime,
                                    const Time swapLengths)
            void updateInterpolators()
            Matrix browse()
        SwaptionVolCube1x(
            const Handle[SwaptionVolatilityStructure]& atmVolStructure,
            const vector[Period]& optionTenors,
            const vector[Period]& swapTenors,
            vector[Spread]& strikeSpreads,
            const vector[vector[Handle[Quote]]]& volSpreads,
            const shared_ptr[SwapIndex]& swapIndexBase,
            const shared_ptr[SwapIndex]& shortSwapIndexBase,
            bool vegaWeightedSmileFit,
            const vector[vector[Handle[Quote]]]& parametersGuess,
            const vector[bool]& isParameterFixed,
            bool isAtmCalibrated,
            const shared_ptr[EndCriteria]& endCriteria,
                # = shared_ptr[EndCriteria](),
            Real maxErrorTolerance, # = Null<Real>(),
            const shared_ptr[OptimizationMethod]& optMethod,
                # = shared_ptr[OptimizationMethod](),
            const Real errorAccept, # = Null<Real>(),
            const bool useMaxError, # = false,
            const Size maxGuesses, # = 50,
            const bool backwardFlat,# = false,
            const Real cutoffStrike) except +# = 0.0001)
        const Matrix& marketVolCube(Size i)
        Matrix sparseSabrParameters()
        Matrix denseSabrParameters()
        Matrix marketVolCube()
        Matrix volCubeAtmCalibrated()
        void sabrCalibrationSection(const Cube& marketVolCube,
                                    Cube& parametersCube,
                                    const Period& swapTenor)
        void recalibration(Real beta,
                           const Period& swapTenor)
        void recalibration(const vector[Real] &beta,
                           const Period& swapTenor)
        void recalibration(const vector[Period] &swapLengths,
                           const vector[Real] &beta,
                           const Period& swapTenor)
        void updateAfterRecalibration()

    cdef cppclass SwaptionVolCubeSabrModel:
        ctypedef SABRInterpolation Interpolation
        ctypedef SabrSmileSection SmileSection

    ctypedef SwaptionVolCube1x[SwaptionVolCubeSabrModel] SwaptionVolCube1
