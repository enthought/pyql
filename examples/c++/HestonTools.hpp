#ifndef HESTONTOOLS_HPP_INCLUDED
#define HESTONTOOLS_HPP_INCLUDED

#include <ql/quantlib.hpp>
#include "CsvHelper.hpp"

using namespace QuantLib;

// evaluate fitting error on benchmark with parameter set
Real HestonPriceBenchmark(Handle<Quote> &s0, std::vector<CALIB> &c, std::vector<RD> &rd,
                          std::vector<double> p, double sdCutOff);

std::vector<double> HestonCalibration(Handle<Quote> &s0, std::vector<CALIB> &c, std::vector<RD> &rd);

void HestonSimulate(std::vector<vector<double> >& res, Handle<Quote> &s0, std::vector<RD> &rd,
                    std::vector<double> p, int nbPaths, int nbSteps, Time horizon, BigNatural seed);

#endif // HESTONTOOLS_HPP_INCLUDED
