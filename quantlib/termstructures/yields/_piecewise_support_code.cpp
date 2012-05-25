/*
 * Cython does not support the full CPP syntax preventing to expose the
 * Piecewise constructors. 
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

    // Creates a YieldTermStructure based on a PiecewiseYieldCurve
    boost::shared_ptr<YieldTermStructure> term_structure_factory(
        std::string& traits, std::string& interpolator, 
        const Date& settlement_date,
        const std::vector<boost::shared_ptr<RateHelper> >& curve_input, 
        DayCounter& 
        day_counter, Real tolerance
    ) {
        
        if(traits.compare("discount") == 0 &&
           interpolator.compare("linear") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<Discount,Linear>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("discount") == 0 &&
                interpolator.compare("loglinear") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<Discount,LogLinear>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("discount") == 0 &&
                interpolator.compare("spline") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<Discount, Cubic>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("forward") == 0 &&
                interpolator.compare("linear") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<ForwardRate,Linear>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("forward") == 0 &&
                interpolator.compare("loglinear") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<ForwardRate,LogLinear>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("forward") == 0 &&
                interpolator.compare("spline") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<ForwardRate,Cubic>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("zero") == 0 &&
                interpolator.compare("linear") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<ZeroYield,Linear>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("zero") == 0 &&
                interpolator.compare("loglinear") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<ZeroYield,LogLinear>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else if(traits.compare("zero") == 0 &&
                interpolator.compare("spline") == 0) {
            boost::shared_ptr<YieldTermStructure> ts(new
            PiecewiseYieldCurve<ZeroYield,Cubic>(settlement_date, 
            curve_input, day_counter, 
            std::vector<Handle<Quote> >(),
            std::vector<Date>(),
            tolerance));
            return ts;
        } else {
            std::cout << "traits = " << traits << std::endl;
            std::cout << "interpolator  = " << interpolator << std::endl;
            QL_FAIL("What/How term structure options not recognized");
        }
    }

}
