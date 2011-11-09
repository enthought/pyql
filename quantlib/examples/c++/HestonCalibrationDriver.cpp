/* -*- mode: c++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

/*!
Calibration of Heston model on SPX vol surface
*/

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

#define DEBUG_OUT true

using namespace QuantLib;

#if defined(QL_ENABLE_SESSIONS)
namespace QuantLib
{

Integer sessionId()
{
    return 0;
}

}
#endif


int main(int, char* [])
{

    Handle<Quote> s0(boost::shared_ptr<Quote>(new SimpleQuote(1290.59)));

    try
    {

// calibration data

        std::fstream file1("/home/phn/dev/R/ValidationModeles/calibration.csv", ios::in);
        if (!file1.is_open())
        {
            std::cout << "Calibration File not found!\n";
            return 1;
        }

        std::vector<CALIB> calibData;
        readCSV_Calib(file1, calibData);
        file1.close();

// interest rates and dividend yield

        std::fstream file2("/home/phn/dev/R/ValidationModeles/rate_div.csv", ios::in);
        if (!file2.is_open())
        {
            std::cout << "Rate/Yield File not found!\n";
            return 1;
        }

        std::vector<RD> RDData;
        readCSV_RD(file2, RDData);
        file2.close();

        std::vector<double> res;

        res = HestonCalibration(s0, calibData, RDData);

        if (DEBUG_OUT)
            std::cout << "Theta: " << res[0] <<
                      "\nKappa: " << res[1] <<
                      "\nsigma: " << res[2] <<
                      "\nrho: " << res[3] <<
                      "\nv0: " << res[4] <<
                      "\nsse: " << res[5] << std::endl;

    }
    catch (std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        return 1;
    }
    catch (...)
    {
        std::cerr << "unknown error" << std::endl;
        return 1;
    }
}
