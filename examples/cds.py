""" Example of CDS pricing with PyQL.

This example is based on the QuantLib CDS official example.

Copyright (C) 2012 Enthought Inc.

"""
from __future__ import print_function

from quantlib.instruments.credit_default_swap import CreditDefaultSwap, SELLER, BUYER
from quantlib.pricingengines.credit.midpoint_cds_engine import MidPointCdsEngine
from quantlib.pricingengines.credit.isda_cds_engine import (
    IsdaCdsEngine, NumericalFix, AccrualBias, ForwardsInCouponPeriod )
from quantlib.settings import Settings
from quantlib.time.api import (
    Date, May, September, Actual365Fixed, Following, TARGET, Period, Months,
    Quarterly, Annual, TwentiethIMM, CDS, Years, Schedule, Unadjusted, ModifiedFollowing,
    WeekendsOnly, Actual360, Thirty360
)
from quantlib.termstructures.credit.api import (
        SpreadCdsHelper, PiecewiseDefaultCurve, ProbabilityTrait, Interpolator )

from quantlib.indexes.euribor import Euribor6M
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.api import (
    FlatForward, DepositRateHelper, SwapRateHelper, PiecewiseYieldCurve, YieldTermStructure)

def example01():
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
    hazard_rate_structure = PiecewiseDefaultCurve.from_reference_date(
            ProbabilityTrait.HazardRate, Interpolator.BackwardFlat, todays_date, instruments, Actual365Fixed()
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
    print()

def example02():
    print("example 2:\n")
    todays_date = Date(25, 9, 2014)
    Settings.instance().evaluation_date = todays_date

    calendar = TARGET()
    term_date = calendar.adjust(todays_date + Period(2, Years), Following)
    cds_schedule =  Schedule(todays_date, term_date, Period(Quarterly),
                             WeekendsOnly(), ModifiedFollowing,
                             ModifiedFollowing,
                             date_generation_rule=CDS)
    for date in cds_schedule:
        print(date)
    print()

    todays_date = Date(21, 10, 2014)
    Settings.instance().evaluation_date = todays_date
    quotes = [0.00006, 0.00045, 0.00081, 0.001840, 0.00256, 0.00337]
    tenors = [1, 2, 3, 6, 9, 12]
    deps = [DepositRateHelper(q, Period(t, Months), 2, calendar, ModifiedFollowing, False, Actual360())
           for q, t in zip(quotes, tenors)]
    tenors = [2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 30]
    quotes = [0.00223, 0.002760, 0.003530, 0.004520, 0.005720, 0.007050, 0.008420, 0.009720, 0.010900,
              0.012870, 0.014970, 0.017, 0.01821]
    swaps = [SwapRateHelper.from_tenor(q, Period(t, Years),
                                       calendar, Annual, ModifiedFollowing,
                                       Thirty360(), Euribor6M(), SimpleQuote(0))
             for q, t in zip(quotes, tenors)]
    helpers = deps + swaps
    YC = PiecewiseYieldCurve("discount", "loglinear", todays_date, helpers, Actual365Fixed())
    YC.extrapolation = True
    print("ISDA rate curve:")
    for h in helpers:
        print("{0}: {1:.6f}\t{2:.6f}".format(h.latest_date,
                                             YC.zero_rate(h.latest_date, Actual365Fixed(), 2).rate,
                                             YC.discount(h.latest_date)))
    defaultTs0 = FlatHazardRate(0, WeekendsOnly(), 0.016739207493630, Actual365Fixed())
    cds_schedule = Schedule(Date(22, 9, 2014), Date(20, 12, 2019), Period(3, Months),
                            WeekendsOnly(), Following, Unadjusted, CDS, False)
    nominal = 100000000
    trade = CreditDefaultSwap(BUYER, nominal, 0.01, cds_schedule, Following,
                            Actual360(), True, True, Date(22, 10, 2014), Actual360(True), True)
    print(trade.coupons_as_fixedratecoupons)
    engine = IsdaCdsEngine(defaultTs0, 0.4, YC, False)
    trade.set_pricing_engine(engine)
    print("reference trade NPV = {0}\n".format(trade.npv))

def example03():
    print("example 3:\n")
    todays_date = Date(13, 6, 2011)
    Settings.instance().evaluation_date = todays_date
    quotes = [0.00445, 0.00949, 0.01234, 0.01776, 0.01935, 0.02084]
    tenors = [1, 2, 3, 6, 9, 12]
    calendar = WeekendsOnly()
    deps = [DepositRateHelper(q, Period(t, Months), 2, calendar, ModifiedFollowing, False, Actual360())
            for q, t in zip(quotes, tenors)]
    quotes = [0.01652, 0.02018, 0.02303, 0.02525, 0.0285, 0.02931, 0.03017, 0.03092, 0.03160, 0.03231,
              0.03367, 0.03419, 0.03411, 0.03411, 0.03412]
    tenors = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 20, 25, 30]
    swaps =  [SwapRateHelper.from_tenor(q, Period(t, Years),
                                        calendar, Annual, ModifiedFollowing,
                                        Thirty360(), Euribor6M(), SimpleQuote(0)) for q, t
              in zip(quotes, tenors)]
    yield_helpers = deps+swaps
    empty_yts = YieldTermStructure()
    spreads = [0.007927, 0.012239, 0.016979, 0.019271, 0.020860]
    tenors = [1, 3, 5, 7, 10]
    spread_helpers = [SpreadCdsHelper(0.007927, Period(6, Months), 1,
                                      WeekendsOnly(), Quarterly, Following, CDS,
                                      Actual360(), 0.4, empty_yts, True, True,
                                      Actual360(True), True, True)] + \
        [SpreadCdsHelper(s, Period(t, Years), 1, WeekendsOnly(), Quarterly, Following, CDS,
                         Actual360(), 0.4, empty_yts, True, True, Actual360(True), True, True)
         for s, t in zip(spreads, tenors)]

    for sh in spread_helpers:
        sh.set_isda_engine_parameters(NumericalFix.Taylor, AccrualBias.NoBias,
                                      ForwardsInCouponPeriod.Piecewise)
    isda_pricer = IsdaCdsEngine(spread_helpers, 0.4, yield_helpers)
    isda_yts = isda_pricer.isda_rate_curve
    isda_cts = isda_pricer.isda_credit_curve
    print("Isda yield curve:")
    for h in yield_helpers:
        d = h.latest_date
        t = isda_yts.time_from_reference(d)
        print(d, t, isda_yts.zero_rate(d, Actual365Fixed()).rate)

    print()
    print("Isda credit curve:")
    for h in spread_helpers:
        d = h.latest_date
        t = isda_cts.time_from_reference(d)
        print(d, t, isda_cts.survival_probability(d))

if __name__ == '__main__':
    example01()
    example02()
    example03()
