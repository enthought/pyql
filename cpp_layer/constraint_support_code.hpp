
/*
 * The HestonHullWhiteCorrelationConstraint is defined in the test suite
 * but is needed to calibrate hybrid Heston-HW models
 *
 * code copied from test-suite/hybridhestonhullwhiteprocess.cpp
 */

#include <ql/types.hpp>
#include <ql/math/optimization/constraint.hpp>


using namespace QuantLib;

namespace PyQL {

   class HestonHullWhiteCorrelationConstraint : public Constraint {
      public:
        HestonHullWhiteCorrelationConstraint(Real equityShortRateCorr);
    };
}
