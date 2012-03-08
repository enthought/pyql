/* -*- mode: c++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

/*
 Copyright (C) 2005, 2007, 2009 Klaus Spanderen

 This file is part of QuantLib, a free-software/open-source library
 for financial quantitative analysts and developers - http://quantlib.org/

 QuantLib is free software: you can redistribute it and/or modify it
 under the terms of the QuantLib license.  You should have received a
 copy of the license along with this program; if not, please email
 <quantlib-dev@lists.sf.net>. The license is also available online at
 <http://quantlib.org/license.shtml>.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
*/

#include <iostream>
#include "hestonmodel.hpp"
#include "utilities.hpp"
#include <ql/instruments/dividendvanillaoption.hpp>
#include <ql/processes/hestonprocess.hpp>
#include <ql/models/equity/hestonmodel.hpp>
#include <ql/models/equity/hestonmodelhelper.hpp>
#include <ql/pricingengines/vanilla/analyticdividendeuropeanengine.hpp>
#include <ql/pricingengines/vanilla/analytichestonengine.hpp>
#include <ql/pricingengines/vanilla/fdamericanengine.hpp>
#include <ql/pricingengines/vanilla/fddividendeuropeanengine.hpp>
#include <ql/pricingengines/vanilla/fdeuropeanengine.hpp>
#include <ql/experimental/finitedifferences/fdhestonbarrierengine.hpp>
#include <ql/experimental/finitedifferences/fdblackscholesbarrierengine.hpp>
#include <ql/experimental/finitedifferences/fdblackscholesvanillaengine.hpp>
#include <ql/experimental/finitedifferences/fdhestonvanillaengine.hpp>
#include <ql/pricingengines/vanilla/mceuropeanhestonengine.hpp>
#include <ql/pricingengines/blackformula.hpp>
#include <ql/time/calendars/target.hpp>
#include <ql/time/calendars/nullcalendar.hpp>
#include <ql/time/daycounters/actual365fixed.hpp>
#include <ql/time/daycounters/actual360.hpp>
#include <ql/time/daycounters/actualactual.hpp>
#include <ql/termstructures/yield/zerocurve.hpp>
#include <ql/termstructures/yield/flatforward.hpp>
#include <ql/math/optimization/levenbergmarquardt.hpp>
#include <ql/time/period.hpp>
#include <ql/quotes/simplequote.hpp>

using namespace QuantLib;


void testBlackCalibration() {

    /* calibrate a Heston model to a constant volatility surface without
       smile. expected result is a vanishing volatility of the volatility.
       In addition theta and v0 should be equal to the constant variance */

    Date today = Date::todaysDate();
    Settings::instance().evaluationDate() = today;

    DayCounter dayCounter = Actual360();
    Calendar calendar = NullCalendar();

    Handle<YieldTermStructure> riskFreeTS(flatRate(0.04, dayCounter));
    Handle<YieldTermStructure> dividendTS(flatRate(0.50, dayCounter));

    std::vector<Period> optionMaturities;
    optionMaturities.push_back(Period(1, Months));
    optionMaturities.push_back(Period(2, Months));
    optionMaturities.push_back(Period(3, Months));
    optionMaturities.push_back(Period(6, Months));
    optionMaturities.push_back(Period(9, Months));
    optionMaturities.push_back(Period(1, Years));
    optionMaturities.push_back(Period(2, Years));

    std::vector<boost::shared_ptr<CalibrationHelper> > options;
    Handle<Quote> s0(boost::shared_ptr<Quote>(new SimpleQuote(1.0)));
    Handle<Quote> vol(boost::shared_ptr<Quote>(new SimpleQuote(0.1)));
    Volatility volatility = vol->value();

    for (Size i = 0; i < optionMaturities.size(); ++i) {
        for (Real moneyness = -1.0; moneyness < 2.0; moneyness += 1.0) {
            // FLOATING_POINT_EXCEPTION
            const Time tau = dayCounter.yearFraction(
                                 riskFreeTS->referenceDate(),
                                 calendar.advance(riskFreeTS->referenceDate(),
                                                  optionMaturities[i]));
        const Real fwdPrice = s0->value()*dividendTS->discount(tau)
                            / riskFreeTS->discount(tau);
        const Real strikePrice = fwdPrice * std::exp(-moneyness * volatility
                                                     * std::sqrt(tau));

        //std::cout << "M " << moneyness   
        //          << " T "       << tau         
        //          << " F "  << fwdPrice    
        //          << " S "    << strikePrice << std::endl;

        options.push_back(boost::shared_ptr<CalibrationHelper>(
                          new HestonModelHelper(optionMaturities[i], calendar,
                                                s0->value(), strikePrice, vol,
                                                riskFreeTS, dividendTS)));
        }
    }

    for (Real sigma = 0.1; sigma < 0.7; sigma += 0.2) {
        const Real v0=0.01;
        const Real kappa=0.2;
        const Real theta=0.02;
        const Real rho=-0.75;

        std::cout << "S " << sigma << std::endl;

        boost::shared_ptr<HestonProcess> process(
            new HestonProcess(riskFreeTS, dividendTS,
                              s0, v0, kappa, theta, sigma, rho));

        boost::shared_ptr<HestonModel> model(new HestonModel(process));
        boost::shared_ptr<PricingEngine> engine(
                                         new AnalyticHestonEngine(model, 96));

        for (Size i = 0; i < options.size(); ++i)
            options[i]->setPricingEngine(engine);

        std::cout  << options[0] << " " << options[0]->modelValue() << " " << options[0]->blackPrice(volatility) << std::endl;

        LevenbergMarquardt om(1e-8, 1e-8, 1e-8);
        model->calibrate(options, om, EndCriteria(400, 40, 1.0e-8,
                                                  1.0e-8, 1.0e-8));

        Real tolerance = 3.0e-3;

        std::cout << "Model sigma " << model->sigma() << " tol " << tolerance 
                  << std::endl;
        if (model->sigma() > tolerance) {
            std::cout << "Failed to reproduce expected sigma"
                        << "\n    calculated: " << model->sigma()
                        << "\n    expected:   " << 0.0
                        << "\n    tolerance:  " << tolerance
                        << std::endl;
        }

        if (std::fabs(model->kappa()
                  *(model->theta()-volatility*volatility)) > tolerance) {
            std::cout << "Failed to reproduce expected theta"
                        << "\n    calculated: " << model->theta() 
                        << "\n    expected:   " << volatility*volatility
                        << std::endl;
        }

        if (std::fabs(model->v0()-volatility*volatility) > tolerance) {
            std::cout   << "Failed to reproduce expected v0"
                        << "\n    calculated: " << model->v0()
                        << "\n    expected:   " << volatility*volatility
                        << std::endl;
        }
    }
}


int main() {

    std::cout << "Starting test" << std::endl;
    testBlackCalibration();
    std::cout << "Done" << std::endl;
    return 0;
}


