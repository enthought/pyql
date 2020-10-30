
/*
 * The HestonHullWhiteCorrelationConstraint is defined in the test suite
 * but is needed to calibrate hybrid Heston-HW models
 *
 * code copied from test-suite/hybridhestonhullwhiteprocess.cpp
 */

#include <ql/types.hpp>
#include <ql/math/optimization/constraint.hpp>
#include <ql/shared_ptr.hpp>

namespace QuantLib {

   class HestonHullWhiteCorrelationConstraint : public Constraint {
      public:
        HestonHullWhiteCorrelationConstraint();
        HestonHullWhiteCorrelationConstraint(double equityShortRateCorr);
    };

    // wrapper function 
    ext::shared_ptr<Constraint> constraint_factory(double equityShortRateCorr);
}

