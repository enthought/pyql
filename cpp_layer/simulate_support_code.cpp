#include<ql/quantlib.hpp>

namespace QuantLib {

    void simulateMP(const boost::shared_ptr<HestonProcess>& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    double *res) {

        typedef PseudoRandom::rsg_type rsg_type; 
        typedef MultiPathGenerator<rsg_type>::sample_type sample_type;

        Time length = horizon;

        Size timeSteps = nbSteps;
        boost::shared_ptr<StochasticProcess> sp = 
        boost::dynamic_pointer_cast<StochasticProcess>(process);
    
        Size assets = sp->size();
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
            sample_type sample = (i%2) ? generator.antithetic()
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

