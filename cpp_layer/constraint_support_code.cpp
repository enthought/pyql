
/*
 * The HestonHullWhiteCorrelationConstraint is defined in the test suite
 *
 * code copied from test-suite/hybridhestonhullwhiteprocess.cpp
 */

#include <ql/types.hpp>
#include <ql/math/optimization/constraint.hpp>
#include <ql/math/functional.hpp>

namespace QuantLib {

   class HestonHullWhiteCorrelationConstraint : public Constraint {
      private:
        class Impl : public Constraint::Impl {
          public:
            Impl(Real equityShortRateCorr)
            : equityShortRateCorr_(equityShortRateCorr) {}

            bool test(const Array& params) const {
                const Real rho = params[3];

                return (  square<Real>()(rho)
                        + square<Real>()(equityShortRateCorr_) <= 1.0);
            }
          private:
            const Real equityShortRateCorr_;
        };
      public:
        HestonHullWhiteCorrelationConstraint() {}
        HestonHullWhiteCorrelationConstraint(Real equityShortRateCorr)
        : Constraint(boost::shared_ptr<Constraint::Impl>(
             new HestonHullWhiteCorrelationConstraint::Impl(
                 equityShortRateCorr))) {}
   };


    typedef boost::shared_ptr<Constraint> CT;

    CT constraint_factory(Real equityShortRateCorr) {
        
        CT ct;
        ct = CT(new 
		HestonHullWhiteCorrelationConstraint(equityShortRateCorr));

	return ct;
  };
}

