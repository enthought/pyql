#include <ql/stochasticprocess.hpp>
#include <ql/timegrid.hpp>
#include <ql/shared_ptr.hpp>

using namespace QuantLib;

namespace PyQL {

  /*
   * Multipath simulator
   */

    void simulateMP(const ext::shared_ptr<QuantLib::StochasticProcess>& process,
                    int nbPaths, TimeGrid& grid, BigNatural seed,
                    bool antithetic_variates, double *res);


}
