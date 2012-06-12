/*
 * Cython does not support the full CPP syntax preventing to expose the
 * Piecewise constructors (e.g. typemap).
 *
 */

#include <vector>
#include <string>
#include <iostream>
#include <ql/termstructures/all.hpp>
#include <ql/time/date.hpp>
#include <ql/time/daycounter.hpp>
#include <ql/math/interpolations/all.hpp>

namespace QuantLib {

    typedef boost::shared_ptr<DefaultProbabilityTermStructure> TS;

    // Creates a DefaultProbabilityTermStructure based on a 
    // PiecewiseDefaultCurve
    boost::shared_ptr<DefaultProbabilityTermStructure> credit_term_structure_factory(
        std::string& traits, std::string& interpolator, 
        const Date& reference_date,
        const std::vector<boost::shared_ptr<DefaultProbabilityHelper> >& instruments, 
        DayCounter& day_counter, Real accuracy
    ) {


        TS ts;
    
        if (traits.compare("HazardRate") == 0) {
           if (interpolator.compare("Linear") == 0) {
                ts = TS(
                    new PiecewiseDefaultCurve<HazardRate,Linear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            } else if (interpolator.compare("LogLinear") == 0) {
                ts = TS(
                    new PiecewiseDefaultCurve<HazardRate,LogLinear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            } else if (interpolator.compare("BackwardFlat") == 0) {
                ts = TS(
                    new PiecewiseDefaultCurve<HazardRate,BackwardFlat>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            }
        } else if (traits.compare("DefaultDensity") == 0) {
           if (interpolator.compare("Linear") == 0) {
               ts = TS(
                    new PiecewiseDefaultCurve<DefaultDensity,Linear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            } else if (interpolator.compare("LogLinear") == 0) {
                ts = TS(
                    new PiecewiseDefaultCurve<DefaultDensity,LogLinear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            } else if (interpolator.compare("BackwardFlat") == 0) {
                ts = TS(
                    new PiecewiseDefaultCurve<DefaultDensity,BackwardFlat>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            }
        } else if (traits.compare("SurvivalProbability") == 0) {
           if (interpolator.compare("Linear") == 0) {
               ts = TS(
                    new PiecewiseDefaultCurve<SurvivalProbability,Linear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            } else if (interpolator.compare("LogLinear") == 0) {
                ts = TS(
                    new PiecewiseDefaultCurve<SurvivalProbability,LogLinear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            } else if (interpolator.compare("BackwardFlat") == 0) {
                ts = TS(
                    new PiecewiseDefaultCurve<SurvivalProbability,BackwardFlat>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
            }
       } else {
            std::cout << "traits = " << traits << std::endl;
            std::cout << "interpolator  = " << interpolator << std::endl;
            QL_FAIL("What/How term structure options not recognized");
        }
        return ts;
    }
}
