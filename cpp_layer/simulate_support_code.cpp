#include <ql/math/randomnumbers/rngtraits.hpp>
#include <ql/methods/montecarlo/multipathgenerator.hpp>
#include <ql/stochasticprocess.hpp>
#include <ql/methods/montecarlo/path.hpp>
#include <algorithm>

/*
 * Multipath simulator. A multipath simulator is needed when the stochastic
 * process involves more than 1 brownian. For example, Heston's model involves
 * the simulation of the variance process and the simulation of the price process
 */

using namespace QuantLib;

namespace PyQL {

    void simulateMP(const boost::shared_ptr<StochasticProcess>& process,
                    int nbPaths, TimeGrid& grid, BigNatural seed,
                    bool antithetic_variates, double *res) {

        typedef PseudoRandom::rsg_type rsg_type; 
        typedef MultiPathGenerator<rsg_type>::sample_type sample_type;

        boost::shared_ptr<StochasticProcess> sp = process;
    
        Size assets = sp->factors();
        rsg_type rsg = PseudoRandom::make_sequence_generator((grid.size() - 1)* assets,
                seed);
        
        MultiPathGenerator<rsg_type> generator(sp, grid, rsg, false);

        // res(nbPaths+1, nbSteps+1)

        // time steps in first row        
        std::copy(grid.begin(), grid.end(), res);
        // fill simulated paths

        for (int i=0; i<nbPaths; ++i) {
            const bool antithetic = (i%2)==0 ? false : true;

              sample_type sample = antithetic_variates ? 
                (antithetic ? generator.antithetic()
		 : generator.next())
                : generator.next();

            Path p1 = sample.value[0];
            std::copy(p1.begin(), p1.end(), res+(i+1)*grid.size());
        }
    }
}

