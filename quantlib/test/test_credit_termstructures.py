""" Unittests for the CDS related classes. """

import  unittest

from quantlib.settings import Settings
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.api import FlatForward
from quantlib.termstructures.credit.api import (
    SpreadCdsHelper, PiecewiseDefaultCurve, FlatHazardRate,
    InterpolatedHazardRateCurve, ProbabilityTrait, Interpolator)
from quantlib.instruments.api import PricingModel
from quantlib.time.api import TARGET, Date, Actual365Fixed, Years, \
        Following, Quarterly, Rule, May, Period, Days
import math

def create_helper():

    calendar = TARGET()

    todays_date = Date(15, May, 2007)
    todays_date = calendar.adjust(todays_date)

    Settings.instance().evaluation_date = todays_date

    flat_rate = SimpleQuote(0.01)
    ts_curve = FlatForward(todays_date, flat_rate, Actual365Fixed())

    recovery_rate = 0.5
    quoted_spreads = 0.0150
    tenor = Period(5, Years)

    helper = SpreadCdsHelper(
            quoted_spreads, tenor, 0, calendar, Quarterly,
            Following, Rule.TwentiethIMM, Actual365Fixed(), recovery_rate, ts_curve,
            model=PricingModel.Midpoint
    )

    return todays_date, helper



class SpreadCdsHelperTestCase(unittest.TestCase):

    def test_create_helper(self):

        todays_date, helper = create_helper()

        self.assertIsNotNone(helper)
        self.assertEqual(helper.latest_date, Date(20, 6, 2012))

class PiecewiseDefaultCurveTestCase(unittest.TestCase):
    def setUp(self):
        self.todays_date, self.helper = create_helper()
        self.d = self.todays_date + Period(3, Years)

    def test_create_piecewise(self):

        for trait in ProbabilityTrait:
            for interpolator in Interpolator:
                curve = PiecewiseDefaultCurve.from_reference_date(
                    trait,
                    interpolator,
                    reference_date=self.todays_date,
                    helpers=[self.helper],
                    daycounter=Actual365Fixed()
                )
                self.assertIsNotNone(curve)

    def test_piecewise_methods(self):

        for trait in ProbabilityTrait:
            for interpolator in Interpolator:
                curve = PiecewiseDefaultCurve.from_reference_date(
                    trait,
                    interpolator,
                    reference_date=self.todays_date,
                    helpers=[self.helper],
                    daycounter=Actual365Fixed()
                )

                if interpolator == Interpolator.LogLinear and \
                   trait in [ProbabilityTrait.HazardRate, ProbabilityTrait.DefaultDensity]:
                    with self.assertRaisesRegexp(RuntimeError,
                                                 'LogInterpolation primitive not implemented'):
                        curve.survival_probability(self.d)
                else:
                    self.assertEqual(curve.survival_probability(self.d),
                                     curve.survival_probability(curve.time_from_reference(self.d)))
                    self.assertEqual(curve.hazard_rate(self.d),
                                     curve.hazard_rate(curve.time_from_reference(self.d)))

    def tearDown(self):
        del self.helper
        self.helper = None

class FlatHazardRateTestCase(unittest.TestCase):

    def setUp(self):
        self.calendar = TARGET()

        todays_date = Date(15, May, 2007)
        self.todays_date = self.calendar.adjust(todays_date)
        self.d = self.todays_date + Period(3, Years)

    def test_create_flat_hazard(self):
        Settings.instance().evaluation_date = self.todays_date
        flat_curve = FlatHazardRate(2, self.calendar, 0.05, Actual365Fixed())
        flat_curve_from_reference_date = FlatHazardRate.from_reference_date(
            self.calendar.advance(self.todays_date, 2, Days), 0.05, Actual365Fixed())
        self.assertIsNotNone(flat_curve)
        self.assertIsNotNone(flat_curve_from_reference_date)
        self.assertEqual(flat_curve.time_from_reference(self.d),
                         flat_curve_from_reference_date.time_from_reference(self.d))
        self.assertAlmostEqual(flat_curve.hazard_rate(self.d), 0.05)
        self.assertAlmostEqual(flat_curve.survival_probability(self.d),
                               math.exp(-0.05*flat_curve.time_from_reference(self.d)))

    def test_flat_hazard_with_quote(self):
        Settings.instance().evaluation_date = self.todays_date
        hazard_rate = SimpleQuote()
        flat_curve = FlatHazardRate(2, self.calendar, hazard_rate, Actual365Fixed())
        for h in [0.01, 0.02, 0.03]:
            hazard_rate.value =  h
            self.assertAlmostEqual(flat_curve.survival_probability(self.d),
                                   math.exp(-h * flat_curve.time_from_reference(self.d)))

class InterpolatedHazardRateTestCase(unittest.TestCase):

    def setUp(self):
        calendar = TARGET()

        todays_date = Date(15, May, 2007)
        self.todays_date = calendar.adjust(todays_date)

    def test_create_interpolated_hazard(self):
        Settings.instance().evaluation_date = self.todays_date

        dates = [self.todays_date + Period(i, Years) for i in [3, 5, 7]]
        hazard_rates =  [0.01, 0.03, 0.05]

        interpolation_date = self.todays_date + Period(4, Years)

        trait = Interpolator.Linear
        interpolated_curve = InterpolatedHazardRateCurve(trait, dates,
                                                         hazard_rates,
                                                         Actual365Fixed())
        t0 = interpolated_curve.time_from_reference(dates[0])
        t1 = interpolated_curve.time_from_reference(interpolation_date)
        t2 = interpolated_curve.time_from_reference(dates[1])
        interpolated_value = hazard_rates[0] + (t1-t0) /(t2-t0) * \
                             (hazard_rates[1] - hazard_rates[0])

        self.assertAlmostEqual(interpolated_value,
                               interpolated_curve.hazard_rate(interpolation_date))
        trait = Interpolator.BackwardFlat
        interpolated_curve = InterpolatedHazardRateCurve(trait, dates,
                                                         hazard_rates,
                                                         Actual365Fixed())
        interpolated_value = hazard_rates[1]
        self.assertAlmostEqual(interpolated_value,
                               interpolated_curve.hazard_rate(interpolation_date))
        trait = Interpolator.LogLinear
        interpolated_curve = InterpolatedHazardRateCurve(trait, dates,
                                                         hazard_rates,
                                                         Actual365Fixed())
        with self.assertRaisesRegexp(RuntimeError,
                                     'LogInterpolation primitive not implemented'):
            hazard_rate = interpolated_curve.hazard_rate(interpolation_date)

    def test_methods(self):
        Settings.instance().evaluation_date = self.todays_date

        dates = [self.todays_date + Period(i, Years) for i in [3, 5, 7]]
        hazard_rates =  [0.01, 0.03, 0.05]
        for trait in [Interpolator.BackwardFlat, Interpolator.Linear]:
            interpolated_curve = InterpolatedHazardRateCurve(trait, dates,
                                                             hazard_rates,
                                                             Actual365Fixed())
            self.assertEqual(dates, interpolated_curve.dates)
            self.assertEqual(interpolated_curve.data, interpolated_curve.hazard_rates)

if __name__ == '__main__':
    unittest.main()
