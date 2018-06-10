#include <ql/stochasticprocess.hpp>
#include <ql/timegrid.hpp>

using namespace QuantLib;

namespace PyQL {

  /*
   * Multipath simulator
   */

    void simulateMP(const boost::shared_ptr<QuantLib::StochasticProcess>& process,
                    int nbPaths, TimeGrid& grid, BigNatural seed,
                    bool antithetic_variates, double *res);


}
