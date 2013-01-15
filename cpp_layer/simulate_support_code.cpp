#include<ql/quantlib.hpp>

/*
 * Multipath simulator. A multipath simulator is needed when the stochastic
 * process involves more than 1 brownian. For example, Heston's model involves
 * the simulation of the variance process and the simulation of the price process
 */

namespace QuantLib {

    void simulateMP(const boost::shared_ptr<StochasticProcess>& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
		    bool antithetic_variates,
                    double *res) {

        typedef PseudoRandom::rsg_type rsg_type; 
        typedef MultiPathGenerator<rsg_type>::sample_type sample_type;

        Time length = horizon;

        Size timeSteps = nbSteps;
        boost::shared_ptr<StochasticProcess> sp = process;
    
        Size assets = sp->factors();
        rsg_type rsg = PseudoRandom::make_sequence_generator(timeSteps*assets,
                       seed);

	MultiPathGenerator<rsg_type> generator(sp, TimeGrid(length, timeSteps),
          rsg, false);

        // res(nbPaths+1, nbSteps+1)

        // time steps in first row        
        double dt = length/nbSteps;
        for (int j=0; j<=nbSteps; ++j)
            res[(0*nbSteps)+j] = dt*j;

        // fill simulated paths

        for (int i=0; i<nbPaths; ++i) {
            const bool antithetic = (i%2)==0 ? false : true;

              sample_type sample = antithetic_variates ? 
                (antithetic ? generator.antithetic()
		 : generator.next())
                : generator.next();

            Path p1 = sample.value[0];
            int j=0;
            for (Path::iterator ip = p1.begin(); ip<p1.end(); ++ip) {
                res[(i+1)*(nbSteps+1)+j] = (*ip);
                j++;
            };
        };
    };
}

