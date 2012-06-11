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

    // Creates a DefaultProbabilityTermStructure based on a 
    // PiecewiseDefaultCurve
    boost::shared_ptr<DefaultProbabilityTermStructure> credit_term_structure_factory(
        std::string& traits, std::string& interpolator, 
        const Date& reference_date,
        const std::vector<boost::shared_ptr<DefaultProbabilityHelper> >& instruments, 
        DayCounter& day_counter, Real accuracy
    ) {
    
        if (traits.compare("HazardRate") == 0) {
           if (interpolator.compare("Linear") == 0) {
                boost::shared_ptr<DefaultProbabilityTermStructure> ts (
                    new PiecewiseDefaultCurve<HazardRate,Linear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
                return ts;
            } else if (interpolator.compare("LogLinear") == 0) {
                boost::shared_ptr<DefaultProbabilityTermStructure> ts (
                    new PiecewiseDefaultCurve<HazardRate,LogLinear>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
                return ts;
            } else if (interpolator.compare("BackwardFlat") == 0) {
                boost::shared_ptr<DefaultProbabilityTermStructure> ts (
                    new PiecewiseDefaultCurve<HazardRate,BackwardFlat>(
                        reference_date, instruments, day_counter, accuracy
                    )
                );
                return ts;
            }
       } else {
            std::cout << "traits = " << traits << std::endl;
            std::cout << "interpolator  = " << interpolator << std::endl;
            QL_FAIL("What/How term structure options not recognized");
        }
    }

}
