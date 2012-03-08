/* -*- mode: c++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

/*!
 TP: C++ for Finance

 Illustration of
 - Quote objects (Derived from test suite quotes.cpp)
 - Observer pattern and lazy evaluation
*/

// the only header you need to use QuantLib
#include <ql/quantlib.hpp>
#include "CsvHelper.hpp"
#include "HestonTools.hpp"

#ifdef BOOST_MSVC
/* Uncomment the following lines to unmask floating-point
   exceptions. Warning: unpredictable results can arise...

   See http://www.wilmott.com/messageview.cfm?catid=10&threadid=9481
   Is there anyone with a definitive word about this?
*/
// #include <float.h>
// namespace { unsigned int u = _controlfp(_EM_INEXACT, _MCW_EM); }
#endif

#include <boost/timer.hpp>
#include <iostream>
#include <iomanip>
#include <string>
#include <fstream>

using namespace QuantLib;

#if defined(QL_ENABLE_SESSIONS)
namespace QuantLib {

    Integer sessionId() {
        return 0;
    }

}
#endif




int main(int, char* []) {


    Handle<Quote> s0(boost::shared_ptr<Quote>(new SimpleQuote(1290.59)));


    try {


// interest rates and dividend yield

        std::fstream file1("/home/phn/dev/R/ValidationModeles/rate_div.csv", ios::in);
        if (!file1.is_open()) {
            std::cout << "Rate/Yield File not found!\n";
            return 1;
        }

        std::vector<RD> RDData;
        readCSV_RD(file1, RDData);
        file1.close();

        std::fstream file2("/home/phn/dev/ModelRisk/Heston/HestonSearch.csv", ios::in);
        if (!file2.is_open()) {
            std::cout << "Heston Parameters File not found!\n";
            return 1;
        }

        std::vector<HESTONPARAMS> HestonPar;
        readCSV_HestonParams(file2, HestonPar);
        file2.close();

        std::vector<double> res(5, 0.0);

        std::cout << "Size of search file: " << HestonPar.size() << std::endl;

        // loop through the parameter set
        // set iTest to run through a few iterations, for testing purpose

        Size iTest = 3;
        for (Size i=0; i<std::min(iTest,HestonPar.size()); ++i) {

            res[0] = HestonPar[i].theta;
            res[1] = HestonPar[i].kappa;
            res[2] = HestonPar[i].sigma;
            res[3] = HestonPar[i].rho;
            res[4] = HestonPar[i].v0;

            int nbPaths = 20000;
            int nbSteps = 100;
            Time horizon = 5;
            BigNatural seed = 0;

            // nbPaths+1 to make room for time steps column
            std::vector< std::vector<double> > paths(nbPaths+1, vector<double>(nbSteps+1, 0));

            HestonSimulate(paths, s0, RDData, res,
                           nbPaths, nbSteps, horizon, seed);

            // write to csv: rows are steps, cols are scenarios
            // first col is time line

            std::ostringstream iCase;
            iCase << i;

            std::cout << "set: " << i << std::endl;

            string fname = "../Heston/Paths/Paths_" + iCase.str() + ".csv";
            write2DtoCsv(paths, fname.c_str(), false);
        }

    } catch (std::exception& e) {
        std::cerr << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "unknown error" << std::endl;
        return 1;
    }
}
