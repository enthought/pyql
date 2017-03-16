#include <ql/math/randomnumbers/rngtraits.hpp>
#include <ql/methods/montecarlo/multipathgenerator.hpp>
#include <ql/stochasticprocess.hpp>
#include <ql/methods/montecarlo/path.hpp>
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
