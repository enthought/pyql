#include<ql/quantlib.hpp>

namespace QuantLib {

    void simulateMP(const boost::shared_ptr<HestonProcess>& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    double *res);
}
