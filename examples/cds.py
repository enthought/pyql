""" Example of CDS pricing with PyQL.

This example is based on the QuantLib CDS official example.

Copyright (C) 2012 Enthought Inc.
 
"""
from __future__ import print_function

from quantlib.instruments.credit_default_swap import CreditDefaultSwap, SELLER
from quantlib.pricingengines.credit import MidPointCdsEngine
from quantlib.settings import Settings
from quantlib.time.api import (
    Date, May, Actual365Fixed, Following, TARGET, Period, Months,
    Quarterly, TwentiethIMM, Years, Schedule, Unadjusted
)
from quantlib.termstructures.credit.api import SpreadCdsHelper, PiecewiseDefaultCurve
from quantlib.termstructures.yields.api import FlatForward

if __name__ == '__main__':

    #*********************
    #***  MARKET DATA  ***
    #*********************
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
    print(target)
    print("Some survival probability values: ")
    print("1Y survival probability: {:%}".format(
            hazard_rate_structure.survival_probability(target)
    ))
    print("               expected: {:%}".format(0.9704))

    print("2Y survival probability: {:%}".format(
        hazard_rate_structure.survival_probability(todays_date + Period(2, Years))
    ))
    print("               expected: {:%}".format(0.9418))

    # reprice instruments
    nominal = 1000000.0;
    #Handle<DefaultProbabilityTermStructure> probability(hazardRateStructure);
    engine = MidPointCdsEngine(hazard_rate_structure, recovery_rate, ts_curve)

    cds_schedule = Schedule(
        todays_date, maturities[0], Period(Quarterly), calendar,
        termination_date_convention=Unadjusted,
        date_generation_rule=TwentiethIMM
    )

    cds_3m = CreditDefaultSwap(
        SELLER, nominal, quoted_spreads[0], cds_schedule, Following,
        Actual365Fixed()
    )

    cds_schedule = Schedule(
        todays_date, maturities[1], Period(Quarterly), calendar,
        termination_date_convention=Unadjusted,
        date_generation_rule=TwentiethIMM
    )

    cds_6m = CreditDefaultSwap(
        SELLER, nominal, quoted_spreads[1], cds_schedule, Following,
        Actual365Fixed()
    )

    cds_schedule = Schedule(
        todays_date, maturities[2], Period(Quarterly), calendar,
        termination_date_convention=Unadjusted,
        date_generation_rule=TwentiethIMM
    )

    cds_1y = CreditDefaultSwap(
        SELLER, nominal, quoted_spreads[2], cds_schedule, Following,
        Actual365Fixed()
    )

    cds_schedule = Schedule(
        todays_date, maturities[3], Period(Quarterly), calendar,
        termination_date_convention=Unadjusted,
        date_generation_rule=TwentiethIMM
    )

    cds_2y = CreditDefaultSwap(
        SELLER, nominal, quoted_spreads[3], cds_schedule, Following,
        Actual365Fixed()
    )

    cds_3m.set_pricing_engine(engine);
    cds_6m.set_pricing_engine(engine);
    cds_1y.set_pricing_engine(engine);
    cds_2y.set_pricing_engine(engine);

    print("Repricing of quoted CDSs employed for calibration: ")
    print("3M fair spread: {}".format(cds_3m.fair_spread))
    print("   NPV:         ", cds_3m.net_present_value)
    print("   default leg: ", cds_3m.default_leg_npv)
    print("   coupon leg:  ", cds_3m.coupon_leg_npv)

    print("6M fair spread: {}".format(cds_6m.fair_spread))
    print("   NPV:         ", cds_6m.net_present_value)
    print("   default leg: ", cds_6m.default_leg_npv)
    print("   coupon leg:  ", cds_6m.coupon_leg_npv)

    print("1Y fair spread: {}".format(cds_1y.fair_spread))
    print("   NPV:         ", cds_1y.net_present_value)
    print("   default leg: ", cds_1y.default_leg_npv)
    print("   coupon leg:  ", cds_1y.coupon_leg_npv)

    print("2Y fair spread: {}".format(cds_2y.fair_spread))
    print("   NPV:         ", cds_2y.net_present_value)
    print("   default leg: ", cds_2y.default_leg_npv)
    print("   coupon leg:  ", cds_2y.coupon_leg_npv)

