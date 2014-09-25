/*
 * Cython does not support the full CPP syntax preventing to expose the
 * Piecewise constructors (e.g. typemap).
 *
 */

#include <string>
#include <iostream>
#include <ql/pricingengines/vanilla/mceuropeanhestonengine.hpp>
#include <ql/processes/hestonprocess.hpp>
#include <ql/math/randomnumbers/rngtraits.hpp>
#include <ql/exercise.hpp>

namespace QuantLib {

    typedef boost::shared_ptr<PricingEngine> PE;

    PE mc_vanilla_engine_factory(
      std::string& trait, 
      std::string& RNG,
      const boost::shared_ptr<HestonProcess>& process,
      bool doAntitheticVariate,
      Size stepsPerYear,
      Size requiredSamples,
      BigNatural seed
    ) {

      PE engine;
    
        if (trait.compare("MCEuropeanHestonEngine") == 0) {
           if (RNG.compare("PseudoRandom") == 0) {
             engine = MakeMCEuropeanHestonEngine<PseudoRandom>(process)
             .withStepsPerYear(stepsPerYear)
             .withAntitheticVariate(doAntitheticVariate)
             .withSamples(requiredSamples)
             .withSeed(seed);
           }
	}
        else {
            std::cout << "traits = " << trait << std::endl;
            std::cout << "RNG  = " << RNG << std::endl;
            QL_FAIL("Engine factory options not recognized");
        }
        return engine;
    }
}
