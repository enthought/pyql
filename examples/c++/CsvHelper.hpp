#ifndef CSVHELPER_HPP_INCLUDED
#define CSVHELPER_HPP_INCLUDED

#include <string>
#include <fstream>
#include <vector>
#include <cstdlib>

#include <iostream>
#include <sstream>

using namespace std;

typedef struct HestonParams
{
    double theta, kappa, sigma, rho, v0, sse;
    HestonParams() {}
    HestonParams(std::vector<std::string> csv) {
    theta = atof(csv[0].c_str());
    kappa = atof(csv[1].c_str());
    sigma = atof(csv[2].c_str());
    rho = atof(csv[3].c_str());
    v0 = atof(csv[4].c_str());
    sse = atof(csv[5].c_str());
    }
} HESTONPARAMS;


typedef struct RateDiv
{
    double T, R, D;
    RateDiv() {}
    RateDiv(std::vector<std::string> csv)
    {
        T = atof(csv[0].c_str());
        R = atof(csv[1].c_str());
        D = atof(csv[2].c_str());
    }

} RD;

ostream &operator<<(ostream &out, RD &p);

typedef struct Calib
{
    double T, R, D, F, K;
    int CP;
    double PB, PA, VB, VA, Vega;
    Calib() {}
    Calib(std::vector<std::string> csv)
    {
        T = atof(csv[0].c_str());
        R = atof(csv[1].c_str());
        D = atof(csv[2].c_str());
        F = atof(csv[3].c_str());
        K = atof(csv[4].c_str());
        CP = atoi(csv[5].c_str());
        PB = atof(csv[6].c_str());
        PA = atof(csv[7].c_str());
        VB = atof(csv[8].c_str());
        VA = atof(csv[9].c_str());
        Vega = atof(csv[10].c_str());
    }

} CALIB;

ostream &operator<<(ostream &out, CALIB &p);

void readCSV(std::fstream& infile,
		std::vector<std::string>& stringArray,
		std::vector<double>& doubleArray,
		std::vector<long>& longArray,
		std::vector<long>& order);

void readCSVToStr(std::istream &input, std::vector< std::vector<std::string> > &output);

void readCSV_Calib(std::istream &input, std::vector<CALIB> &output);
void readCSV_RD(std::istream &input, std::vector<RD> &output);
void readCSV_HestonParams(std::istream &input, std::vector<HESTONPARAMS> &output);

template <typename T>
void readCSV_T(std::istream &input, std::vector<T> &output);

void write2DtoCsv(std::vector<std::vector<double> > &v, const char* filename, bool byRow);

#endif // CSVHELPER_HPP_INCLUDED
