
/*
 * The HestonHullWhiteCorrelationConstraint is defined in the test suite
 * but is needed to calibrate hybrid Heston-HW models
 *
 * code copied from test-suite/hybridhestonhullwhiteprocess.cpp
 */

#include <ql/types.hpp>
#include <ql/math/optimization/constraint.hpp>

namespace QuantLib {

   class HestonHullWhiteCorrelationConstraint : public Constraint {
      public:
        HestonHullWhiteCorrelationConstraint(double equityShortRateCorr);
    };

  double MySimpleAdd(double x, double y);
}
