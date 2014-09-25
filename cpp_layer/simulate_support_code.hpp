#include <ql/math/randomnumbers/rngtraits.hpp>
#include <ql/methods/montecarlo/multipathgenerator.hpp>
#include <ql/stochasticprocess.hpp>
#include <ql/methods/montecarlo/path.hpp>

using namespace QuantLib;

namespace PyQL {

  /*
   * Multipath simulator
   */

    void simulateMP(const boost::shared_ptr<QuantLib::StochasticProcess>& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    bool antithetic_variates, double *res);


}
