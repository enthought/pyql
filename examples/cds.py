"""
 Copyright (C) 2012 Enthought Inc.
"""

from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.time.api import (
    Calendar, Date, May, Actual365Fixed, Following, TARGET, Period, Months,
    Quarterly, TwentiethIMM, Years
)
from quantlib.termstructures.credit.api import SpreadCdsHelper, PiecewiseDefaultCurve
from quantlib.termstructures.yields.api import FlatForward

if __name__ == '__main__':

    #*********************
    #***  MARKET DATA  ***
    #*********************/
    calendar = TARGET()

    todays_date = Date(15, May, 2007)
    # must be a business day
    todays_date = calendar.adjust(todays_date)

    Settings.instance().evaluation_date = todays_date

    # dummy curve
    ts_curve = FlatForward(
        reference_date=todays_date, forward=0.01, daycounter=Actual365Fixed()
    )

    # In Lehmans Brothers "guide to exotic credit derivatives"
    # p. 32 there's a simple case, zero flat curve with a flat CDS
    # curve with constant market spreads of 150 bp and RR = 50%
    # corresponds to a flat 3% hazard rate. The implied 1-year
    # survival probability is 97.04% and the 2-years is 94.18%

    # market
    recovery_rate = 0.5
    quoted_spreads = [0.0150, 0.0150, 0.0150, 0.0150 ]
    tenors = [Period(i, Months) for i in [3, 6, 12, 24]]
    maturities = [
        calendar.adjust(todays_date + tenors[i], Following) for i in range(4)
    ]
    instruments = []
    for i in range(4):
        helper = SpreadCdsHelper(
            quoted_spreads[i], tenors[i], 0, calendar, Quarterly,
            Following, TwentiethIMM, Actual365Fixed(), recovery_rate, ts_curve
        )

        instruments.append(helper)

    # Bootstrap hazard rates
    hazard_rate_structure = PiecewiseDefaultCurve(
        'HazardRate', 'BackwardFlat', todays_date, instruments, Actual365Fixed()
    )

    #vector<pair<Date, Real> > hr_curve_data = hazardRateStructure->nodes();

    #cout << "Calibrated hazard rate values: " << endl ;
    #for (Size i=0; i<hr_curve_data.size(); i++) {
    #    cout << "hazard rate on " << hr_curve_data[i].first << " is "
    #         << hr_curve_data[i].second << endl;
    #}
    #cout << endl;


    target = todays_date + Period(1, Years)
    print target
    print "Some survival probability values: "
    print "1Y survival probability: {:%}".format(
            hazard_rate_structure.survival_probability(target)
    )
    print "               expected: {:%}".format(0.9704)

    print "2Y survival probability: {:%}".format(
        hazard_rate_structure.survival_probability(todays_date + 2*Years)
    )
    print "               expected: {:%}".format(0.9418)

    # reprice instruments
    nominal = 1000000.0;
    #Handle<DefaultProbabilityTermStructure> probability(hazardRateStructure);
    engine = MidPointCdsEngine(hazard_rate_structure, recovery_rate, ts_curve)

    #Schedule cdsSchedule =
    #    MakeSchedule().from(todaysDate).to(maturities[0])
    #                  .withFrequency(Quarterly)
    #                  .withCalendar(calendar)
    #                  .withTerminationDateConvention(Unadjusted)
    #                  .withRule(DateGeneration::TwentiethIMM);
    #CreditDefaultSwap cds_3m(Protection::Seller,
    #                         nominal,
    #                         quoted_spreads[0],
    #                         cdsSchedule,
    #                         Following,
    #                         Actual365Fixed());

    #cdsSchedule =
    #    MakeSchedule().from(todaysDate).to(maturities[1])
    #                  .withFrequency(Quarterly)
    #                  .withCalendar(calendar)
    #                  .withTerminationDateConvention(Unadjusted)
    #                  .withRule(DateGeneration::TwentiethIMM);
    #CreditDefaultSwap cds_6m(Protection::Seller,
    #                         nominal,
    #                         quoted_spreads[1],
    #                         cdsSchedule,
    #                         Following,
    #                         Actual365Fixed());

    #cdsSchedule =
    #    MakeSchedule().from(todaysDate).to(maturities[2])
    #                  .withFrequency(Quarterly)
    #                  .withCalendar(calendar)
    #                  .withTerminationDateConvention(Unadjusted)
    #                  .withRule(DateGeneration::TwentiethIMM);
    #CreditDefaultSwap cds_1y(Protection::Seller,
    #                         nominal,
    #                         quoted_spreads[2],
    #                         cdsSchedule,
    #                         Following,
    #                         Actual365Fixed());

    #cdsSchedule =
    #    MakeSchedule().from(todaysDate).to(maturities[3])
    #                  .withFrequency(Quarterly)
    #                  .withCalendar(calendar)
    #                  .withTerminationDateConvention(Unadjusted)
    #                  .withRule(DateGeneration::TwentiethIMM);
    #CreditDefaultSwap cds_2y(Protection::Seller,
    #                         nominal,
    #                         quoted_spreads[3],
    #                         cdsSchedule,
    #                         Following,
    #                         Actual365Fixed());

    #cds_3m.setPricingEngine(engine);
    #cds_6m.setPricingEngine(engine);
    #cds_1y.setPricingEngine(engine);
    #cds_2y.setPricingEngine(engine);

    #cout << "Repricing of quoted CDSs employed for calibration: " << endl;
    #cout << "3M fair spread: " << io::rate(cds_3m.fairSpread()) << endl
    #     << "   NPV:         " << cds_3m.NPV() << endl
    #     << "   default leg: " << cds_3m.defaultLegNPV() << endl
    #     << "   coupon leg:  " << cds_3m.couponLegNPV() << endl
    #     << endl;

    #cout << "6M fair spread: " << io::rate(cds_6m.fairSpread()) << endl
    #     << "   NPV:         " << cds_6m.NPV() << endl
    #     << "   default leg: " << cds_6m.defaultLegNPV() << endl
    #     << "   coupon leg:  " << cds_6m.couponLegNPV() << endl
    #     << endl;

    #cout << "1Y fair spread: " << io::rate(cds_1y.fairSpread()) << endl
    #     << "   NPV:         " << cds_1y.NPV() << endl
    #     << "   default leg: " << cds_1y.defaultLegNPV() << endl
    #     << "   coupon leg:  " << cds_1y.couponLegNPV() << endl
    #     << endl;

    #cout << "2Y fair spread: " << io::rate(cds_2y.fairSpread()) << endl
    #     << "   NPV:         " << cds_2y.NPV() << endl
    #     << "   default leg: " << cds_2y.defaultLegNPV() << endl
    #     << "   coupon leg:  " << cds_2y.couponLegNPV() << endl
    #     << endl;

    #cout << endl << endl;

    #Real seconds  = timer.elapsed();
    #Integer hours = Integer(seconds/3600);
    #seconds -= hours * 3600;
    #Integer minutes = Integer(seconds/60);
    #seconds -= minutes * 60;
    #cout << "Run completed in ";
    #if (hours > 0)
    #    cout << hours << " h ";
    #if (hours > 0 || minutes > 0)
    #    cout << minutes << " m ";
    #cout << fixed << setprecision(0)
    #     << seconds << " s" << endl;

    #return 0;

