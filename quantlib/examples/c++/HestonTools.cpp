#include<ql/quantlib.hpp>
#include "CsvHelper.hpp"

using namespace QuantLib;

namespace {

    Real getCalibrationError(
        std::vector<boost::shared_ptr<CalibrationHelper> > & options) {
        Real sse = 0;
        for (Size i = 0; i < options.size(); ++i) {
            const Real diff = options[i]->calibrationError()*100.0;
            sse += diff*diff;
        }
        return std::sqrt(sse/options.size());
    }

}

namespace {

    void simulateMP(const boost::shared_ptr<StochasticProcess>& process,
                    int nbPaths, int nbSteps, Time horizon, BigNatural seed,
                    std::vector < vector <double> >& res) {

        typedef PseudoRandom::rsg_type rsg_type;
        typedef MultiPathGenerator<rsg_type>::sample_type sample_type;

        // cannot simulate past the end of the curves if any

        Time maxTY = horizon;
        Time maxTD = horizon;
        try {
            boost::shared_ptr<HestonProcess>
            hp = boost::dynamic_pointer_cast<HestonProcess>(process);
            maxTY = hp->riskFreeRate()->maxTime();
            maxTD = hp->dividendYield()->maxTime();
        } catch (...) {};

        Time length = std::min(horizon, std::min(maxTY, maxTD));

        Size timeSteps = nbSteps;
        Size assets = process->size();
        rsg_type rsg = PseudoRandom::make_sequence_generator(timeSteps*assets,
                       seed);
        MultiPathGenerator<rsg_type> generator(process,
                                               TimeGrid(length, timeSteps),
                                               rsg, false);



        // time steps in first column
        double dt = length/nbSteps;
        for (int i=0; i<=nbSteps; ++i)
            res[0][i] = dt*i;

        for (int i=0; i<nbPaths; ++i) {
            sample_type sample = (i%2) ? generator.antithetic()
                                 : generator.next();

            Path p1 = sample.value[0];
            int k=0;
            for (Path::iterator ip = p1.begin(); ip<p1.end(); ++ip) {
                res[i+1][k++] = (*ip);
            };

        }
    }
}

void HestonSimulate(std::vector<vector<double> >& res, Handle<Quote> &s0,
                    std::vector<RD> &rd,
                    std::vector<double> p, int nbPaths, int nbSteps, Time horizon, BigNatural seed) {

    Date settlementDate(24, January, 2011);
    SavedSettings backup;
    Settings::instance().evaluationDate() = settlementDate;

    Real theta = p[0];
    Real kappa = p[1];
    Real sigma = p[2];
    Real rho = p[3];
    Real v0 = p[4];


    if(false)
    std::cout << "Theta: " << theta <<
    "\nKappa: " << kappa <<
    "\nsigma: " << sigma <<
    "\nrho: " << rho <<
    "\nv0: " << v0 << std::endl;

    DayCounter dayCounter = Actual365Fixed();
    Calendar calendar = TARGET();

    std::vector<Date> dates;
    std::vector<Rate> rates;
    std::vector<Rate> div;

    // this is indispensable: expiry in Heston helper is computed from YC settlement date

    dates.push_back(settlementDate);
    rates.push_back(rd[0].R);
    div.push_back(rd[0].D);
    for (Size i = 0; i < rd.size(); ++i) {
        Integer days = 365*rd[i].T;
        dates.push_back(settlementDate + days);

        rates.push_back(rd[i].R);
        div.push_back(rd[i].D);
    }

    Date dtLast = settlementDate + ((int) 365*rd[rd.size()-1].T);

    std::cout << "Last curve date: " << dtLast << std::endl;

    Integer days = (rd[rd.size()-1].T+1)*365;
    dates.push_back(settlementDate + days);
    rates.push_back(rd[rd.size()-1].R);
    div.push_back(rd[rd.size()-1].D);

    if(false) std::cout << "Heston simulation: TS..." << std::endl;

    Handle<YieldTermStructure> riskFreeTS(
        boost::shared_ptr<YieldTermStructure>(
            new ZeroCurve(dates, rates, dayCounter)));

    Handle<YieldTermStructure> dividendTS(
        boost::shared_ptr<YieldTermStructure>(
            new ZeroCurve(dates, div, dayCounter)));

    Volatility vol = .3;

    Handle<BlackVolTermStructure> volTS(
        boost::shared_ptr<BlackVolTermStructure>(
            new BlackConstantVol(settlementDate, calendar, vol,
                                 dayCounter)));

    boost::shared_ptr<StochasticProcess> process(new HestonProcess(
                riskFreeTS, dividendTS, s0, v0, kappa, theta, sigma, rho));

    boost::shared_ptr<StochasticProcess1D> BSprocess(
        new BlackScholesMertonProcess(s0, dividendTS, riskFreeTS, volTS));

    std::cout << "Heston simulation: calling simulateMP..." << std::endl;

    simulateMP(process, nbPaths, nbSteps, horizon, seed, res);
}

// evaluate fitting error on benchmark with parameter set
Real HestonPriceBenchmark(Handle<Quote> &s0, std::vector<CALIB> &c, std::vector<RD> &rd,
                          std::vector<double> p, double sdCutOff) {

    Date settlementDate(24, January, 2011);
    SavedSettings backup;
    Settings::instance().evaluationDate() = settlementDate;

    Real theta = p[0];
    Real kappa = p[1];
    Real sigma = p[2];
    Real rho = p[3];
    Real v0 = p[4];

    std::cout << "Theta: " << theta <<
    "\nKappa: " << kappa <<
    "\nsigma: " << sigma <<
    "\nrho: " << rho <<
    "\nv0: " << v0 << std::endl;

    DayCounter dayCounter = Actual365Fixed();
    Calendar calendar = TARGET();

    std::vector<Date> dates;
    std::vector<Rate> rates;
    std::vector<Rate> div;

    // this is indispensable: expiry in Heston helper is computed from YC settlement date

    dates.push_back(settlementDate);
    rates.push_back(rd[0].R);
    div.push_back(rd[0].D);
    for (Size i = 0; i < rd.size(); ++i) {
        Integer days = 365*rd[i].T;
        dates.push_back(settlementDate + days);

        rates.push_back(rd[i].R);
        div.push_back(rd[i].D);
    }

    Date dtLast = settlementDate + ((int) 365*rd[rd.size()-1].T);

    std::cout << "Last curve date: " << dtLast << std::endl;

    Integer days = (rd[rd.size()-1].T+1)*365;
    dates.push_back(settlementDate + days);
    rates.push_back(rd[rd.size()-1].R);
    div.push_back(rd[rd.size()-1].D);


    std::cout << "Heston model Benchmark Pricing: TS..." << std::endl;

    Handle<YieldTermStructure> riskFreeTS(
        boost::shared_ptr<YieldTermStructure>(
            new ZeroCurve(dates, rates, dayCounter)));

    Handle<YieldTermStructure> dividendTS(
        boost::shared_ptr<YieldTermStructure>(
            new ZeroCurve(dates, div, dayCounter)));

    Volatility vol = 2.0;

    Handle<BlackVolTermStructure> volTS(
        boost::shared_ptr<BlackVolTermStructure>(
            new BlackConstantVol(settlementDate, calendar, vol,
                                 dayCounter)));


    boost::shared_ptr<BlackScholesMertonProcess> BSprocess(
        new BlackScholesMertonProcess(s0, dividendTS, riskFreeTS, volTS));
//    boost::shared_ptr<PricingEngine> BSengine(
//        new AnalyticEuropeanEngine(BSprocess));

    boost::shared_ptr<HestonProcess> process(new HestonProcess(
                riskFreeTS, dividendTS, s0, v0, kappa, theta, sigma, rho));

    boost::shared_ptr<PricingEngine> engine(new AnalyticHestonEngine(
                                                boost::shared_ptr<HestonModel>(new HestonModel(process)), 64));

    std::cout << "Heston model Benchmark Pricing: engine set ..." << std::endl;

    IncrementalStatistics errorStat;
    vector<Real> error;

    ofstream myfile;
    Volatility ivol;

    Real errorBid;
    Real errorAsk;


//        myfile.open ("dump.csv", ios::out|ios::trunc); // this is the default
//        myfile << "T, dm, y, CP, PB, Calc, PA, Vega, iVol, ErrorBid, ErrorAsk" << std::endl;

    for (Size i = 0; i < c.size(); ++i) {
        Integer days = 365*c[i].T;
        //std::cout << "Expiry dates: " << dtExpiry << std::endl;
        Period maturity((int)((days+3)/7.), Weeks); // round to weeks
        Date dtExpiry = calendar.advance(riskFreeTS->referenceDate(),
                                         maturity);

        if (i==0)
            std::cout << dtExpiry << std::endl;

        // Time tau = riskFreeTS->dayCounter().yearFraction(
        //                       riskFreeTS->referenceDate(), dtExpiry);

        boost::shared_ptr<StrikedTypePayoff> payoff(
            new PlainVanillaPayoff(Option::Call, c[i].K));

        boost::shared_ptr<Exercise> exercise(new EuropeanExercise(dtExpiry));

        VanillaOption option(payoff, exercise);
        option.setPricingEngine(engine);
        Real calculated = option.NPV();

        // option.setPricingEngine(BSengine);

        if (calculated >0) {
            try {
                ivol = option.impliedVolatility(calculated, BSprocess, 1.e-6, 1000, .1, 10);
                errorBid  = std::max((c[i].VB-ivol), 0.0)*100;
                errorAsk =  std::max((ivol-c[i].VA), 0.0)*100;
            } catch (...) {
                errorBid  = 0.0;
                errorAsk =  0.0;
            };
        } else {
            vol = 0.0;
            errorAsk = 0.0;
            errorBid = 0.0;
        };

        error.push_back(errorBid+errorAsk);
//            myfile << c[i].T << "," << dtExpiry << "," << c[i].CP << "," << c[i].PB << "," << calculated << "," << c[i].PA << "," << c[i].Vega << "," << ivol << "," << errorBid << "," << errorAsk << std::endl;
    }

    // remove outliers and calculate sse

    errorStat.addSequence(error.begin(), error.end());
    Real sse = errorStat.standardDeviation();

    for (Size i=0; i<error.size(); ++i)
        if (abs(error[i]) > sdCutOff*sse) error[i] = 0.0;

    errorStat.reset();
    errorStat.addSequence(error.begin(), error.end());
    sse = errorStat.standardDeviation();
    return sse;
}


std::vector<double> HestonCalibration(Handle<Quote> &s0, std::vector<CALIB> &c, std::vector<RD> &rd) {

    std::cout << "Heston model calibration using SP500 volatility data..." << std::endl;

    Date settlementDate(24, January, 2011);
    SavedSettings backup;
    Settings::instance().evaluationDate() = settlementDate;

    DayCounter dayCounter = Actual365Fixed();
    Calendar calendar = TARGET();

    std::vector<Date> dates;
    std::vector<Rate> rates;
    std::vector<Rate> div;

    // this is indispensable: expiry in Heston helper is computed from YC settlement date
    dates.push_back(settlementDate);
    rates.push_back(rd[0].R);
    div.push_back(rd[0].D);

    for (Size i = 0; i < rd.size(); ++i) {
        Integer days = 365*rd[i].T;
        dates.push_back(settlementDate + days);

        rates.push_back(rd[i].R);
        div.push_back(rd[i].D);
    }

    Date dtLast = settlementDate + ((int) 365*rd[rd.size()-1].T);

    std::cout << "Last curve date: " << dtLast << std::endl;

    Integer days = (rd[rd.size()-1].T+1)*365;
    dates.push_back(settlementDate + days);
    rates.push_back(rd[rd.size()-1].R);
    div.push_back(rd[rd.size()-1].D);

    std::cout << "Heston model calibration: TS..." << std::endl;

    Handle<YieldTermStructure> riskFreeTS(
        boost::shared_ptr<YieldTermStructure>(
            new ZeroCurve(dates, rates, dayCounter)));

    Handle<YieldTermStructure> dividendTS(
        boost::shared_ptr<YieldTermStructure>(
            new ZeroCurve(dates, div, dayCounter)));

    std::cout << "Heston model calibration: Options ..." << std::endl;

    std::vector<boost::shared_ptr<CalibrationHelper> > options;
    std::vector<Real> w;
    std::vector<Real> ivRange;

    for (Size i = 0; i < c.size(); ++i) {

        // exclude options that are too much in/out
        double strike = c[i].K;
        if((strike/s0->value() > 1.25) | (strike/s0->value() < .75)) continue;


        Integer days = 365*c[i].T;
        Date dtExpiry = settlementDate + days;
        //std::cout << "Expiry dates: " << dtExpiry << std::endl;
        Period maturity((int)((days+3)/7.), Weeks); // round to weeks
        //Period maturity(days, Days);

        Handle<Quote> volB(boost::shared_ptr<Quote>(
                               new SimpleQuote(c[i].VB)));
        options.push_back(boost::shared_ptr<CalibrationHelper>(
                              new HestonModelHelper(maturity, calendar,
                                                    s0->value(), c[i].K, volB,
                                                    riskFreeTS, dividendTS,
                                                    CalibrationHelper::ImpliedVolError)));

        // w.push_back(c[i].Vega);
        w.push_back(1.0);

        ivRange.push_back(c[i].VA-c[i].VB);

        Handle<Quote> volA(boost::shared_ptr<Quote>(
                               new SimpleQuote(c[i].VA)));
        options.push_back(boost::shared_ptr<CalibrationHelper>(
                              new HestonModelHelper(maturity, calendar,
                                                    s0->value(), c[i].K, volA,
                                                    riskFreeTS, dividendTS,
                                                    CalibrationHelper::ImpliedVolError)));

        //w.push_back(c[i].Vega);
        w.push_back(1.0);
        ivRange.push_back(c[i].VA-c[i].VB);

//        std::cout << c[i].VA  << " " << c[i].VB << " " << c[i].K << std::endl;

    }


    const Real v0=0.1;
    const Real kappa=1.0;
    const Real theta=0.1;
    const Real sigma=0.5;
    const Real rho=-0.5;

    boost::shared_ptr<HestonProcess> process(new HestonProcess(
                riskFreeTS, dividendTS, s0, v0, kappa, theta, sigma, rho));

    boost::shared_ptr<HestonModel> model(new HestonModel(process));

    boost::shared_ptr<PricingEngine> engine(
        new AnalyticHestonEngine(model, 64));

    for (Size i = 0; i < options.size(); ++i)
        options[i]->setPricingEngine(engine);

    std::cout << "Heston model calibration: Calibration..." << std::endl;

    LevenbergMarquardt om(1e-8, 1e-8, 1e-8);
    // max iterations
    // max stationary state iterations
    // root eps
    // function eps
    // gradient norm eps
    // the cost function is in model.cpp

    Constraint ct;
    model->calibrate(options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8),ct,w);

    std::cout << model->endCriteria() << std::endl;

    Real sse = 0;
    Real tw = 0.;
    for (Size i = 0; i < options.size(); ++i) {
        const Real diff = options[i]->calibrationError()*100.0;
        sse += diff*diff*w[i];
        tw += w[i];
    }


    sse /= tw;
    std::cout << " Weighted Mean Sq Error: " << sse << " Weighted Mean abs error: " << std::sqrt(sse) << std::endl;

    // write fitted vs actual

    if(false) {
        ofstream myfile;

    myfile.open ("HestonCalibrationResults.csv", ios::out|ios::trunc); // this is the default
    myfile << "T, Strike, VolBid, VolAsk, VolModel\n";

    int j = 0;
    for (Size i = 0; i < c.size(); i++) {
        double modelValue = options[j]->modelValue();
        double marketValue = options[j]->marketValue();

        std::cout << c[i].T << " " << c[i].K << " " << modelValue << " " << marketValue << std::endl;
        if(marketValue > .1) {
        double modelVol = options[j]->impliedVolatility(modelValue, 1e-12, 5000, .001, 10);

        myfile << c[i].T << "," << c[i].K  << "," << c[i].VB << "," << c[i].VA << "," << modelVol << "\n";
        };
        j+=2;
    };
    myfile.close();
    };

    std::vector<double> res;

    res.push_back(model->theta());
    res.push_back(model->kappa());
    res.push_back(model->sigma());
    res.push_back(model->rho());
    res.push_back(model->v0());
    res.push_back(sse);

    if (1==0) {
        boost::shared_ptr<BatesModel> batesModel(
            new BatesModel(process,1.1098, -0.1285, 0.1702));

        boost::shared_ptr<PricingEngine> batesEngine(
            new BatesEngine(batesModel, 64));

        batesModel->calibrate(options, om,
                              EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8));


        std::cout << " nu " << batesModel->nu() << " delta " << batesModel->delta() << " lambda " << batesModel->lambda()
        << std::endl;

        // Real calc_bates = getCalibrationError(options);

        Real sse_b = 0;
        tw = 0.;
        for (Size i = 0; i < options.size(); ++i) {
            const Real diff = options[i]->calibrationError()*100.0;
            sse_b += diff*diff*w[i];
            tw += w[i];
        }

        sse_b /= tw;
        std::cout << " Bates: Weighted Mean Sq Error: " << sse_b << " Weighted Mean abs error: " << std::sqrt(sse_b) << std::endl;


        // reset process
        process = boost::shared_ptr<HestonProcess>(new HestonProcess(
                      riskFreeTS, dividendTS, s0, model->v0(), model->kappa(), model->theta(), model->sigma(), model->rho()));


        Real calc_jd;

        boost::shared_ptr<BatesDetJumpModel> modelDetJump(
            new BatesDetJumpModel(process,1, -0.1));

        boost::shared_ptr<BatesDetJumpEngine> engineDetJump(
            new BatesDetJumpEngine(modelDetJump, 64));


        for (Size j = 0; j < options.size(); ++j) {
            options[j]->setPricingEngine(engineDetJump);
        }

        modelDetJump->calibrate(options, om,
                                EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8));

        std::cout << " nu " << modelDetJump->nu() << " delta " << modelDetJump->delta() << " lambda "
        << modelDetJump->lambda() << " kappalambda " << modelDetJump->kappaLambda()
        << " thetaLambda " << modelDetJump->thetaLambda() << std::endl;

        calc_jd = std::fabs(getCalibrationError(options));
        std::cout << " Weighted Mean Sq Error (DetJump): " << calc_jd << std::endl;



        boost::shared_ptr<BatesDoubleExpModel> modelDExpBates(
            new BatesDoubleExpModel(process, 1.0));

        boost::shared_ptr<BatesDoubleExpEngine> engineDExpBates(
            new BatesDoubleExpEngine(modelDExpBates, 64));


        for (Size j = 0; j < options.size(); ++j) {
            options[j]->setPricingEngine(engineDExpBates);
        }

        modelDExpBates->calibrate(options, om,
                                  EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8));

        std::cout << "p " << modelDExpBates->p() << " nuDown " << modelDExpBates->nuDown() << " nuUp "
        << modelDExpBates->nuUp() << " lambda " << modelDExpBates->lambda() << std::endl;

        calc_jd = std::fabs(getCalibrationError(options));
        std::cout << " Weighted Mean Sq Error (DoubleExp): " << calc_jd << std::endl;

        boost::shared_ptr<BatesDoubleExpDetJumpModel> modelDExpDJBates(
            new BatesDoubleExpDetJumpModel(process, 1.0));

        boost::shared_ptr<BatesDoubleExpDetJumpEngine> engineDExpDJBates(
            new BatesDoubleExpDetJumpEngine(modelDExpDJBates, 64));


        for (Size j = 0; j < options.size(); ++j) {
            options[j]->setPricingEngine(engineDExpDJBates);
        }

        modelDExpDJBates->calibrate(options, om,
                                    EndCriteria(1000, 40, 1.0e-8, 1.0e-8, 1.0e-8));

        std::cout << "p " << modelDExpDJBates->p() << " nuDown " << modelDExpDJBates->nuDown() << " nuUp "
        << modelDExpDJBates->nuUp() << " lambda " << modelDExpDJBates->lambda() << std::endl;

        calc_jd = std::fabs(getCalibrationError(options));
        std::cout << " Weighted Mean Sq Error (DoubleExpDetJump): " << calc_jd << std::endl;
    };

    return res;
}
