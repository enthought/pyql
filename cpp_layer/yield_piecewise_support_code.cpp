/*
 * Cython does not support the full CPP syntax preventing to expose the
 * Piecewise constructors (e.g. typemap).
 *
 * This code is inspired by the RQuantLib code and provides a factory function
 * for PiecewiseYieldCurve.
 *
 */
#include <vector>
#include <string>
#include <iostream>
#include <ql/termstructures/all.hpp>
#include <ql/time/date.hpp>
#include <ql/time/daycounter.hpp>

namespace QuantLib {

    typedef boost::shared_ptr<YieldTermStructure> TS;

    // Creates a YieldTermStructure based on a PiecewiseYieldCurve
    TS term_structure_factory(
        std::string& traits, std::string& interpolator, 
        const Date& settlement_date,
        const std::vector<boost::shared_ptr<RateHelper> >& curve_input, 
        DayCounter& 
        day_counter, Real tolerance
    ) {
        
        TS ts;

        if (traits.compare("discount") == 0) {
            if (interpolator.compare("linear") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<Discount,Linear>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
                    )
                );
            } else if (interpolator.compare("loglinear") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<Discount,LogLinear>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
                    )
                );
            } else if (interpolator.compare("spline") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<Discount, Cubic>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
                    )
                );
            }
        } else if (traits.compare("forward") == 0) {
            if (interpolator.compare("linear") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<ForwardRate,Linear>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
                    )
                );
            } else if (interpolator.compare("loglinear") == 0) {
                ts =  TS(
                    new PiecewiseYieldCurve<ForwardRate,LogLinear>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
                    )
                );
            } else if (interpolator.compare("spline") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<ForwardRate,Cubic>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
                    )
                );

            }
        } else if(traits.compare("zero") == 0) {
            if (interpolator.compare("linear") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<ZeroYield,Linear>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
                    )
                );
            } else if (interpolator.compare("loglinear") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<ZeroYield,LogLinear>(
                        settlement_date, 
                        curve_input, day_counter, 
                        tolerance
                    )
                );
            } else if (interpolator.compare("spline") == 0) {
                ts = TS(
                    new PiecewiseYieldCurve<ZeroYield,Cubic>(
                        settlement_date, curve_input, day_counter, 
                        tolerance
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
