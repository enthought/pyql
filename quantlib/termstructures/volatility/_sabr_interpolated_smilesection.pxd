include "../../types.pxi"
from _smilesection cimport SmileSection
from quantlib._quote cimport Quote
from quantlib.handle cimport Handle, shared_ptr
from quantlib.time._daycounter cimport DayCounter
from quantlib.time._date cimport Date
from quantlib.math._optimization cimport EndCriteria, OptimizationMethod
from libcpp.vector cimport vector
from libcpp cimport bool

cdef extern from 'ql/termstructures/volatility/sabrinterpolatedsmilesection.hpp' namespace 'QuantLib':
    cdef cppclass SabrInterpolatedSmileSection(SmileSection):
        SabrInterpolatedSmileSection(
            const Date& optionDate,
            const Handle[Quote]& forward,
            vector[Rate]& strikes,
            bool hasFloatingStrikes,
            const Handle[Quote]& atmVolatility,
            const vector[Handle[Quote]]& volHandles,
            Real alpha, Real beta, Real nu, Real rho,
            bool isAlphaFixed, bool isBetaFixed,
            bool isNuFixed, bool isRhoFixed,
            bool vegaWeighted,
            shared_ptr[EndCriteria]& endCriteria, #= shared_ptr[EndCriteria](),
            shared_ptr[OptimizationMethod]& method, #= boost::shared_ptr[OptimizationMethod](),
            const DayCounter& dc, #= Actual365Fixed(),
            const Real shift #= 0.0
        ) except +
        Real alpha()
        Real beta()
        Real nu()
        Real rho()
        Real rmsError()
        Real maxError()
        EndCriteria.Type endCriteria()
