/* -*- mode: c++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

/*!
 Basic test -- C++ version
 */

// the only header you need to use QuantLib
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

#include <iostream>
#include <iomanip>

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

    try
    {

        // set up dates
        Calendar calendar = TARGET();
        Date todaysDate(05, September, 2010);
        Date settlementDate(07, September, 2010);

        Settings::instance().evaluationDate() = todaysDate;

        // our options
        Option::Type option_type(Option::Put);
        Real underlying = 36;
        Real strike = 40;
        Spread dividendYield = 0.00;
        Rate riskFreeRate = 0.06;
        Volatility volatility = 0.20;
        Date maturity(7, September, 2011);
        DayCounter dayCounter = Actual365Fixed();

        std::cout << "Option type = "  << option_type << std::endl;
        std::cout << "Maturity = "        << maturity << std::endl;
        std::cout << "Underlying price = "        << underlying << std::endl;
        std::cout << "Strike = "                  << strike << std::endl;
        std::cout << "Risk-free interest rate = " << io::rate(riskFreeRate)
                  << std::endl;
        std::cout << "Dividend yield = " << io::rate(dividendYield)
                  << std::endl;
        std::cout << "Volatility = " << io::volatility(volatility)
                  << std::endl;
        std::cout << std::endl;

        Handle<Quote> underlyingH(
            boost::shared_ptr<Quote>(new SimpleQuote(underlying)));

        // bootstrap the yield/dividend/vol curves
        Handle<YieldTermStructure> flatTermStructure(
            boost::shared_ptr<YieldTermStructure>(
                new FlatForward(settlementDate, riskFreeRate, dayCounter)));

        Handle<YieldTermStructure> flatDividendTS(
            boost::shared_ptr<YieldTermStructure>(
                new FlatForward(settlementDate, dividendYield, dayCounter)));

        Handle<BlackVolTermStructure> flatVolTS(
            boost::shared_ptr<BlackVolTermStructure>(
                new BlackConstantVol(settlementDate, calendar, volatility,
                                     dayCounter)));

        boost::shared_ptr<BlackScholesMertonProcess> bsmProcess(
            new BlackScholesMertonProcess(underlyingH, flatDividendTS,
                                          flatTermStructure, flatVolTS));

        boost::shared_ptr<Exercise> europeanExercise(
            new EuropeanExercise(maturity));


        boost::shared_ptr<StrikedTypePayoff> payoff(
            new PlainVanillaPayoff(option_type, strike));

        // options
        VanillaOption europeanOption(payoff, europeanExercise);

        // Analytic formulas:

        // Black-Scholes for European
        std::string method = "Black-Scholes";
        europeanOption.setPricingEngine(boost::shared_ptr<PricingEngine>(
                                            new AnalyticEuropeanEngine(bsmProcess)));

        std::cout <<  method
                  << " PV: " << europeanOption.NPV()
                  << std::endl;

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
