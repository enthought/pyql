/*
 * Cython does not support the full CPP syntax preventing to expose the
 * Piecewise constructors. 
 *
 * This code is inspired by the RQuantLib code and provides a factory function
 * for PiecewiseYieldCurve.
 *
 */

#include <ql/termstructures/all.hpp>
#include <ql/time/date.hpp>
#include <ql/time/daycounter.hpp>
#include <vector>
#include <string>

namespace QuantLib {

    // Creates a DefaultProbabilityTermStructure based on a PiecewiseDefaultCurve
    boost::shared_ptr<DefaultProbabilityTermStructure> credit_term_structure_factory(
        std::string& traits, std::string& interpolator, 
        const Date& reference_date,
        const std::vector<boost::shared_ptr<DefaultProbabilityHelper> >& curve_input,
        DayCounter& day_counter, 
        Real tolerance
    );
}

