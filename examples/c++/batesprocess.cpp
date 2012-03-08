/* -*- mode: c++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

/*
Test of bates model constructor from bates process
*/

#include <iostream>
#include <iomanip>
#include "utilities.hpp"
#include <ql/quantlib.hpp>

#ifdef BOOST_MSVC
/* Uncomment the following lines to unmask floating-point
  exceptions. Warning: unpredictable results can arise...

  See http://www.wilmott.com/messageview.cfm?catid=10&threadid=9481
  Is there anyone with a definitive word about this?
*/
// #include <float.h>
// namespace { unsigned int u = _controlfp(_EM_INEXACT, _MCW_EM); }
#endif


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

using namespace QuantLib;

int main() {

    Date today = Date::todaysDate();
    Settings::instance().evaluationDate() = today;

    DayCounter dayCounter = Actual360();

    Handle<YieldTermStructure> riskFreeTS(flatRate(0.04, dayCounter));
    Handle<YieldTermStructure> dividendTS(flatRate(0.50, dayCounter));

    Handle<Quote> s0(boost::shared_ptr<Quote>(new SimpleQuote(100.0)));


    const Real sigma = 0.1;
    const Real v0=0.01;
    const Real kappa=0.2;
    const Real theta=0.02;
    const Real rho=-0.75;
    const Real lambda = .123;
    const Real nu = .0123;
    const Real delta = .00123;

    boost::shared_ptr<BatesProcess> process(
	new BatesProcess(riskFreeTS, dividendTS,
			  s0, v0, kappa, theta, sigma, rho, lambda, nu, delta));
    
    std::cout << "Arguments from Bates process:" << std::endl;
    std::cout << "lambda: " << process->lambda() << " delta: " << process->delta() << std::endl;
    
    boost::shared_ptr<BatesModel> model(new BatesModel(process));

    std::cout << "Arguments from Bates model:" << std::endl;
    std::cout << "lambda: " << model->lambda() << " delta: " << model->delta() << std::endl;
    
return 0;
}


