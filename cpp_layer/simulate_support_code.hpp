#include<ql/quantlib.hpp>

namespace QuantLib {

  /*
   * Multipath simulator
   */

    void simulateMP(const boost::shared_ptr<StochasticProcess>& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    bool antithetic_variates, double *res);


}
