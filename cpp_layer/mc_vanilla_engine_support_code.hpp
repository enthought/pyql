/*
 * Cython does not support the full CPP syntax preventing to expose the
 * Piecewise constructors (e.g. typemap).
 *
 */

#include <string>
#include <ql/pricingengines/vanilla/mceuropeanhestonengine.hpp>
#include <ql/processes/hestonprocess.hpp>
#include <ql/math/randomnumbers/rngtraits.hpp>

namespace QuantLib {

    boost::shared_ptr<PricingEngine> mc_vanilla_engine_factory(
      std::string& trait, 
      std::string& rng,
      const boost::shared_ptr<HestonProcess>& process,
      bool doAntitheticVariate,
      Size stepsPerYear,
      Size requiredSamples,
      BigNatural seed);
}
